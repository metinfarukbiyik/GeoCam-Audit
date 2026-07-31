//
//  CameraSessionEngine.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import OSLog

/// AVCaptureSession'ı kendine ait seri kuyrukta yöneten motor.
/// Tüm oturum işlemleri ana thread dışında yürütülür.
nonisolated final class CameraSessionEngine: @unchecked Sendable {

    /// Oturumun kendi kendine düzelemediği durumları bildiren olaylar.
    enum Event: Sendable {
        case runtimeError
        case interrupted
        case interruptionEnded
    }

    let session = AVCaptureSession()
    let events: AsyncStream<Event>

    private let eventContinuation: AsyncStream<Event>.Continuation
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()
    private let queue = DispatchQueue(label: CameraConstants.Session.queueLabel)

    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private var pendingCaptures: [Int64: PhotoCaptureDelegate] = [:]
    private var notificationObservers: [any NSObjectProtocol] = []

    private var captureMode: CaptureMode = .photo
    private var captureRotationAngle: CGFloat?
    private var recordingDelegate: MovieCaptureDelegate?
    private var recordingContinuation: CheckedContinuation<URL, any Error>?

    /// Oturuma bağlı aktif kamera cihazı. Rotasyon takibi için gereklidir.
    private(set) var activeDevice: AVCaptureDevice?

    init() {
        (events, eventContinuation) = AsyncStream.makeStream()
        observeSessionNotifications()
    }

    deinit {
        notificationObservers.forEach(NotificationCenter.default.removeObserver)
        eventContinuation.finish()
    }

    // MARK: - Session Lifecycle

    func configure(facing: CameraFacing, mode: CaptureMode) async throws {
        try await perform { [self] in
            guard videoInput == nil else { return }

            session.beginConfiguration()
            defer { session.commitConfiguration() }

            try attachInput(for: facing)
            try applyCaptureMode(mode)
        }
    }

    func start() async {
        try? await perform { [self] in
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    func stop() async {
        try? await perform { [self] in
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }

    var isRunning: Bool { session.isRunning }

    // MARK: - Configuration Changes

    func switchCamera(to facing: CameraFacing) async throws {
        try await perform { [self] in
            session.beginConfiguration()
            defer { session.commitConfiguration() }

            if let videoInput {
                session.removeInput(videoInput)
                self.videoInput = nil
            }

            do {
                try attachInput(for: facing)
            } catch {
                // Yeni cihaz bağlanamazsa oturumu kullanılabilir bırakmak için eskisine dönülür.
                try? attachInput(for: facing.toggled)
                refreshOutputs(isFrontFacing: facing.toggled == .front)
                throw error
            }

            refreshOutputs(isFrontFacing: facing == .front)
        }
    }

    func setCaptureMode(_ mode: CaptureMode) async throws {
        try await perform { [self] in
            guard captureMode != mode else { return }

            session.beginConfiguration()
            defer { session.commitConfiguration() }

            try applyCaptureMode(mode)
        }
    }

    func setCaptureRotationAngle(_ angle: CGFloat) {
        queue.async { [self] in
            captureRotationAngle = angle
            applyRotationAngle()
        }
    }

    /// Video modunda flaş yerine sürekli ışık kullanılır.
    func setTorch(enabled: Bool) {
        queue.async { [self] in
            guard let device = activeDevice, device.hasTorch, device.isTorchAvailable else { return }

            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }

                device.torchMode = enabled ? .on : .off
            } catch {
                AppLogger.camera.error("Işık ayarlanamadı: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    /// Aktif cihazda seçilebilir yakınlaştırma basamaklarını döndürür.
    func availableZoomFactors() async -> [CameraZoomFactor] {
        await performValue { [self] in
            guard let device = activeDevice else { return [.wide] }
            return availableZoomFactorsUnlocked(on: device)
        }
    }

    func setZoomFactor(_ factor: CameraZoomFactor) async {
        await performValue { [self] in
            guard let device = activeDevice else { return }
            apply(deviceZoom: deviceZoomFactor(for: factor, on: device), on: device, animated: true)
        }
    }

    /// Pinch sırasında kullanılan sürekli zoom aralığı ve güncel değer.
    func zoomRange() async -> (min: CGFloat, max: CGFloat, current: CGFloat) {
        await performValue { [self] in
            guard let device = activeDevice else { return (1, 1, 1) }

            return (
                device.minAvailableVideoZoomFactor,
                device.maxAvailableVideoZoomFactor,
                device.videoZoomFactor
            )
        }
    }

    /// Pinch için animasyonsuz zoom; basamak düğmeleri animasyonlu geçer.
    func setDeviceZoomFactor(_ factor: CGFloat, animated: Bool) async -> CGFloat {
        await performValue { [self] in
            guard let device = activeDevice else { return 1 }

            let target = min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
            apply(deviceZoom: target, on: device, animated: animated)
            return device.videoZoomFactor
        }
    }

    /// Cihaz zoom değerine en yakın 0.5 / 1 / 2 basamağını bulur.
    func nearestZoomFactor(for deviceFactor: CGFloat) async -> CameraZoomFactor {
        await performValue { [self] in
            guard let device = activeDevice else { return .wide }

            let available = availableZoomFactorsUnlocked(on: device)
            return available.min { lhs, rhs in
                abs(deviceZoomFactor(for: lhs, on: device) - deviceFactor)
                    < abs(deviceZoomFactor(for: rhs, on: device) - deviceFactor)
            } ?? .wide
        }
    }

    private func apply(deviceZoom target: CGFloat, on device: AVCaptureDevice, animated: Bool) {
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }

            if animated {
                device.ramp(
                    toVideoZoomFactor: target,
                    withRate: Float(wideSwitchOverFactor(on: device) / CameraConstants.Zoom.rampDuration)
                )
            } else {
                device.videoZoomFactor = target
            }
        } catch {
            AppLogger.camera.error("Zoom ayarlanamadı: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func availableZoomFactorsUnlocked(on device: AVCaptureDevice) -> [CameraZoomFactor] {
        let wideFactor = wideSwitchOverFactor(on: device)
        var factors: [CameraZoomFactor] = []

        let ultraFactor = CameraConstants.Zoom.ultraWideDeviceFactor
        if ultraFactor < wideFactor, ultraFactor >= device.minAvailableVideoZoomFactor {
            factors.append(.ultraWide)
        }

        factors.append(.wide)

        let teleFactor = deviceZoomFactor(for: .telephoto, on: device)
        if teleFactor <= device.maxAvailableVideoZoomFactor {
            factors.append(.telephoto)
        }

        return factors
    }

    /// Görünen 0.5× / 1× / 2× değerlerini cihazın videoZoomFactor ölçeğine çevirir.
    private func deviceZoomFactor(for factor: CameraZoomFactor, on device: AVCaptureDevice) -> CGFloat {
        let wideFactor = wideSwitchOverFactor(on: device)

        switch factor {
        case .ultraWide:
            return CameraConstants.Zoom.ultraWideDeviceFactor
        case .wide:
            return wideFactor
        case .telephoto:
            return wideFactor * CameraZoomFactor.telephoto.rawValue / CameraZoomFactor.wide.rawValue
        }
    }

    private func wideSwitchOverFactor(on device: AVCaptureDevice) -> CGFloat {
        device.virtualDeviceSwitchOverVideoZoomFactors
            .map { CGFloat(truncating: $0) }
            .sorted()
            .first ?? 1
    }

    // MARK: - Photo Capture

    func capturePhoto(flashMode: CameraFlashMode, facing: CameraFacing) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [self] in
                guard session.isRunning, session.outputs.contains(photoOutput) else {
                    continuation.resume(throwing: CameraError.captureFailed)
                    return
                }

                let settings = makePhotoSettings(flashMode: flashMode)
                let identifier = settings.uniqueID

                let delegate = PhotoCaptureDelegate { [weak self] result in
                    if let self {
                        queue.async { self.pendingCaptures[identifier] = nil }
                    }
                    continuation.resume(with: result)
                }

                pendingCaptures[identifier] = delegate
                applyMirroring(to: photoOutput, isEnabled: facing == .front)
                photoOutput.capturePhoto(with: settings, delegate: delegate)
            }
        }
    }

    // MARK: - Video Capture

    func startRecording(to url: URL) async throws {
        try await perform { [self] in
            guard session.isRunning, session.outputs.contains(movieOutput), !movieOutput.isRecording else {
                throw CameraError.recordingFailed
            }

            let delegate = MovieCaptureDelegate { [weak self] result in
                guard let self else { return }

                queue.async { self.completeRecording(with: result) }
            }

            recordingDelegate = delegate
            movieOutput.startRecording(to: url, recordingDelegate: delegate)
        }
    }

    func stopRecording() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            queue.async { [self] in
                guard movieOutput.isRecording else {
                    continuation.resume(throwing: CameraError.recordingFailed)
                    return
                }

                recordingContinuation = continuation
                movieOutput.stopRecording()
            }
        }
    }

    // MARK: - Private: Configuration

    private func applyCaptureMode(_ mode: CaptureMode) throws {
        captureMode = mode

        switch mode {
        case .photo:
            detachMovieOutput()
            session.sessionPreset = .photo
            try attachPhotoOutput()
        case .video:
            detachPhotoOutput()
            session.sessionPreset = .high
            try attachMovieOutput()
        }

        refreshOutputs(isFrontFacing: videoInput?.device.position == .front)
    }

    private func attachInput(for facing: CameraFacing) throws {
        let device = try device(for: facing)
        let input = try AVCaptureDeviceInput(device: device)

        guard session.canAddInput(input) else { throw CameraError.configurationFailed }

        session.addInput(input)
        videoInput = input
        activeDevice = device
        resetZoom(on: device)
    }

    /// Yeni cihazda varsayılan 1× geniş açıya dönülür.
    private func resetZoom(on device: AVCaptureDevice) {
        let wideFactor = device.virtualDeviceSwitchOverVideoZoomFactors
            .map { CGFloat(truncating: $0) }
            .sorted()
            .first ?? 1
        let target = min(max(wideFactor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)

        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            device.videoZoomFactor = target
        } catch {
            AppLogger.camera.error("Zoom sıfırlanamadı: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func attachPhotoOutput() throws {
        guard !session.outputs.contains(photoOutput) else { return }
        guard session.canAddOutput(photoOutput) else { throw CameraError.configurationFailed }

        session.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .quality
    }

    private func detachPhotoOutput() {
        guard session.outputs.contains(photoOutput) else { return }

        session.removeOutput(photoOutput)
    }

    private func attachMovieOutput() throws {
        attachAudioInputIfAuthorized()

        guard !session.outputs.contains(movieOutput) else { return }
        guard session.canAddOutput(movieOutput) else { throw CameraError.configurationFailed }

        session.addOutput(movieOutput)
        movieOutput.maxRecordedDuration = CMTime(
            seconds: CameraConstants.Video.maximumDuration,
            preferredTimescale: 1
        )
    }

    private func detachMovieOutput() {
        if session.outputs.contains(movieOutput) {
            session.removeOutput(movieOutput)
        }

        if let audioInput {
            session.removeInput(audioInput)
            self.audioInput = nil
        }
    }

    /// Mikrofon izni verilmemişse ses girişi eklenmez; video sessiz kaydedilir.
    private func attachAudioInputIfAuthorized() {
        guard audioInput == nil,
              AVCaptureDevice.authorizationStatus(for: .audio) == .authorized,
              let device = AVCaptureDevice.default(for: .audio),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else { return }

        session.addInput(input)
        audioInput = input
    }

    /// Girdi ya da çıktı değiştiğinde çözünürlük, aynalama ve rotasyonu yeniden uygular.
    private func refreshOutputs(isFrontFacing: Bool) {
        updateMaxPhotoDimensions()
        configureCaptureResponsiveness()
        applyRotationAngle()
        applyMirroring(to: photoOutput, isEnabled: isFrontFacing)
        applyMirroring(to: movieOutput, isEnabled: isFrontFacing)
    }

    /// Art arda çekimde deklanşörün beklememesi için duyarlı çekim özellikleri açılır.
    /// Sıfır deklanşör gecikmesi duyarlı çekimin, o da hızlı önceliklendirmenin ön koşuludur.
    private func configureCaptureResponsiveness() {
        guard session.outputs.contains(photoOutput) else { return }

        if photoOutput.isZeroShutterLagSupported {
            photoOutput.isZeroShutterLagEnabled = true
        }

        if photoOutput.isResponsiveCaptureSupported {
            photoOutput.isResponsiveCaptureEnabled = true
        }

        if photoOutput.isFastCapturePrioritizationSupported {
            photoOutput.isFastCapturePrioritizationEnabled = true
        }
    }

    private func updateMaxPhotoDimensions() {
        guard session.outputs.contains(photoOutput) else { return }

        // Desteklenmeyen bir çözünürlükle çekim yapılmaması için aktif formata göre güncellenir.
        if let dimensions = videoInput?.device.activeFormat.supportedMaxPhotoDimensions.last {
            photoOutput.maxPhotoDimensions = dimensions
        }

        // Ertelenmiş teslimde didFinishProcessingPhoto hiç çağrılmaz, yerine düşük çözünürlüklü
        // bir vekil gelir. Overlay tam çözünürlüklü kareye basılacağı için kapatılır.
        photoOutput.isAutoDeferredPhotoDeliveryEnabled = false
    }

    private func applyRotationAngle() {
        guard let angle = captureRotationAngle else { return }

        for output in [photoOutput, movieOutput] as [AVCaptureOutput] {
            guard let connection = output.connection(with: .video),
                  connection.isVideoRotationAngleSupported(angle)
            else { continue }

            connection.videoRotationAngle = angle
        }
    }

    private func applyMirroring(to output: AVCaptureOutput, isEnabled: Bool) {
        guard let connection = output.connection(with: .video),
              connection.isVideoMirroringSupported
        else { return }

        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = isEnabled
    }

    private func device(for facing: CameraFacing) throws -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: facing.preferredDeviceTypes,
            mediaType: .video,
            position: facing.devicePosition
        )

        guard let device = discoverySession.devices.first else { throw CameraError.deviceUnavailable }
        return device
    }

    private func makePhotoSettings(flashMode: CameraFlashMode) -> AVCapturePhotoSettings {
        let settings = if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            AVCapturePhotoSettings()
        }

        settings.photoQualityPrioritization = .quality
        settings.maxPhotoDimensions = photoOutput.maxPhotoDimensions

        let requestedFlashMode = flashMode.captureFlashMode
        if photoOutput.supportedFlashModes.contains(requestedFlashMode) {
            settings.flashMode = requestedFlashMode
        }

        return settings
    }

    private func completeRecording(with result: Result<URL, any Error>) {
        recordingDelegate = nil

        guard let continuation = recordingContinuation else {
            // Kullanıcı durdurmadan (örneğin süre sınırıyla) biten kayıtlar burada düşer.
            AppLogger.camera.debug("Beklenmeyen kayıt sonucu yok sayıldı.")
            return
        }

        recordingContinuation = nil
        continuation.resume(with: result)
    }

    // MARK: - Private: Notifications

    /// AVFoundation, capture kaynağı XPC üzerinden koptuğunda oturumu sessizce durdurur.
    /// Bu bildirimler olmadan kamera siyah ekranda kalır.
    private func observeSessionNotifications() {
        let center = NotificationCenter.default
        let continuation = eventContinuation

        notificationObservers = [
            center.addObserver(
                forName: AVCaptureSession.runtimeErrorNotification,
                object: session,
                queue: nil
            ) { _ in continuation.yield(.runtimeError) },

            center.addObserver(
                forName: AVCaptureSession.wasInterruptedNotification,
                object: session,
                queue: nil
            ) { _ in continuation.yield(.interrupted) },

            center.addObserver(
                forName: AVCaptureSession.interruptionEndedNotification,
                object: session,
                queue: nil
            ) { _ in continuation.yield(.interruptionEnded) }
        ]
    }

    /// Verilen işi seri kuyrukta çalıştırıp sonucunu bekler.
    private func perform(_ work: @escaping @Sendable () throws -> Void) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                continuation.resume(with: Result { try work() })
            }
        }
    }

    private func performValue<T: Sendable>(_ work: @escaping @Sendable () -> T) async -> T {
        await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: work())
            }
        }
    }
}
