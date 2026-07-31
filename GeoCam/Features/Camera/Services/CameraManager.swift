//
//  CameraManager.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import OSLog

/// AVFoundation tabanlı kamera yöneticisi.
/// Oturum işlerini CameraSessionEngine'e devreder, arayüz durumunu ana thread'de tutar.
@MainActor
@Observable
final class CameraManager: CameraManaging {

    let previewLayer: AVCaptureVideoPreviewLayer

    private(set) var permissionStatus: PermissionStatus
    private(set) var isSessionRunning = false
    private(set) var isRecording = false
    private(set) var configuration: CameraConfiguration = .default
    private(set) var zoomFactor: CameraZoomFactor = .wide
    private(set) var availableZoomFactors: [CameraZoomFactor] = [.wide]
    private(set) var deviceZoomFactor: CGFloat = 1

    private let engine = CameraSessionEngine()
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var rotationObservers: [NSKeyValueObservation] = []
    private var sessionEventTask: Task<Void, Never>?
    /// Kullanıcı arayüzü kamerayı açık bekliyor mu? Arka planda otomatik kurtarma yapılmaz.
    private var shouldBeRunning = false

    init() {
        previewLayer = AVCaptureVideoPreviewLayer(session: engine.session)
        previewLayer.videoGravity = .resizeAspectFill
        permissionStatus = PermissionStatus(AVCaptureDevice.authorizationStatus(for: .video))
        observeSessionEvents()
    }

    // MARK: - Permission

    func requestPermission() async -> PermissionStatus {
        let current = PermissionStatus(AVCaptureDevice.authorizationStatus(for: .video))
        guard current == .notDetermined else {
            permissionStatus = current
            return current
        }

        let isGranted = await AVCaptureDevice.requestAccess(for: .video)
        permissionStatus = isGranted ? .authorized : .denied
        return permissionStatus
    }

    // MARK: - Session Lifecycle

    func prepareSession() async throws {
        guard permissionStatus.isAuthorized else { throw CameraError.permissionDenied }

        try await engine.configure(facing: configuration.facing, mode: configuration.captureMode)
        await refreshZoomState(resetToWide: true)
        observeRotation()
    }

    func startSession() async {
        shouldBeRunning = true
        await engine.start()
        isSessionRunning = engine.isRunning
    }

    func stopSession() async {
        shouldBeRunning = false
        await engine.stop()
        isSessionRunning = engine.isRunning
    }

    // MARK: - Configuration

    func setFlashMode(_ flashMode: CameraFlashMode) {
        configuration.flashMode = flashMode

        if configuration.captureMode == .video {
            engine.setTorch(enabled: flashMode == .on)
        }
    }

    func setCaptureMode(_ mode: CaptureMode) async throws {
        guard configuration.captureMode != mode, !isRecording else { return }

        if mode == .video {
            await requestMicrophoneAccessIfNeeded()
        } else {
            engine.setTorch(enabled: false)
        }

        try await engine.setCaptureMode(mode)
        configuration.captureMode = mode
        observeRotation()
    }

    func switchCamera() async throws {
        guard !isRecording else { return }

        let target = configuration.facing.toggled
        try await engine.switchCamera(to: target)
        configuration.facing = target
        await refreshZoomState(resetToWide: true)
        observeRotation()
    }

    func setZoomFactor(_ factor: CameraZoomFactor) async {
        guard availableZoomFactors.contains(factor), zoomFactor != factor else { return }

        await engine.setZoomFactor(factor)
        zoomFactor = factor
        let range = await engine.zoomRange()
        deviceZoomFactor = range.current
    }

    func setDeviceZoomFactor(_ factor: CGFloat) async {
        deviceZoomFactor = await engine.setDeviceZoomFactor(factor, animated: false)
        zoomFactor = await engine.nearestZoomFactor(for: deviceZoomFactor)
    }

    func snapZoomToNearestFactor() async {
        let nearest = await engine.nearestZoomFactor(for: deviceZoomFactor)
        await engine.setZoomFactor(nearest)
        zoomFactor = nearest
        deviceZoomFactor = await engine.zoomRange().current
    }

    // MARK: - Capture

    func capturePhoto() async throws -> Data {
        try await engine.capturePhoto(
            flashMode: configuration.flashMode,
            facing: configuration.facing
        )
    }

    func startRecording() async throws {
        guard !isRecording else { throw CameraError.recordingFailed }

        if configuration.flashMode == .on {
            engine.setTorch(enabled: true)
        }

        do {
            try await engine.startRecording(to: Self.makeRecordingURL())
            isRecording = true
        } catch {
            engine.setTorch(enabled: false)
            throw error
        }
    }

    func stopRecording() async throws -> URL {
        defer {
            isRecording = false
            engine.setTorch(enabled: false)
        }

        return try await engine.stopRecording()
    }

    // MARK: - Session Recovery

    private func observeSessionEvents() {
        sessionEventTask = Task { [weak self, events = engine.events] in
            for await event in events {
                guard let self else { return }
                await handle(event)
            }
        }
    }

    private func handle(_ event: CameraSessionEngine.Event) async {
        switch event {
        case .runtimeError, .interruptionEnded:
            await restartIfNeeded()
        case .interrupted:
            isSessionRunning = false
        }
    }

    /// Oturum beklenmedik şekilde durduysa sınırlı sayıda yeniden başlatma dener.
    private func restartIfNeeded() async {
        guard shouldBeRunning, permissionStatus.isAuthorized else { return }

        for _ in 0..<CameraConstants.Recovery.maxRestartAttempts {
            guard shouldBeRunning, !engine.isRunning else { break }

            try? await Task.sleep(for: CameraConstants.Recovery.restartDelay)
            await engine.start()
        }

        isSessionRunning = engine.isRunning

        if !isSessionRunning {
            AppLogger.camera.error("Kamera oturumu yeniden başlatılamadı.")
        }
    }

    // MARK: - Rotation

    /// Cihaz yönü değiştikçe önizleme ve çıktı açılarını güncel tutar.
    private func observeRotation() {
        guard let device = engine.activeDevice else { return }

        rotationObservers.removeAll()

        let coordinator = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
        rotationCoordinator = coordinator

        apply(previewAngle: coordinator.videoRotationAngleForHorizonLevelPreview)
        engine.setCaptureRotationAngle(coordinator.videoRotationAngleForHorizonLevelCapture)

        // KVO blokları @Sendable olmadan çevresindeki MainActor izolasyonunu miras alır;
        // bildirim ana thread dışından gelirse çalışma anında trap üretir.
        rotationObservers = [
            coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.new]) { @Sendable [weak self] _, change in
                guard let angle = change.newValue else { return }
                Task { @MainActor in self?.apply(previewAngle: angle) }
            },
            coordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: [.new]) { @Sendable [weak self] _, change in
                guard let angle = change.newValue else { return }
                Task { @MainActor in self?.engine.setCaptureRotationAngle(angle) }
            }
        ]
    }

    private func apply(previewAngle angle: CGFloat) {
        guard let connection = previewLayer.connection,
              connection.isVideoRotationAngleSupported(angle)
        else { return }

        connection.videoRotationAngle = angle
    }

    // MARK: - Helpers

    private func refreshZoomState(resetToWide: Bool) async {
        availableZoomFactors = await engine.availableZoomFactors()
        let range = await engine.zoomRange()
        deviceZoomFactor = range.current

        if resetToWide || !availableZoomFactors.contains(zoomFactor) {
            let preferred = availableZoomFactors.contains(.wide) ? CameraZoomFactor.wide : availableZoomFactors.first ?? .wide
            await engine.setZoomFactor(preferred)
            zoomFactor = preferred
            deviceZoomFactor = await engine.zoomRange().current
        }
    }

    private func requestMicrophoneAccessIfNeeded() async {
        guard AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined else { return }

        // İzin verilmezse kayıt sessiz devam eder; kullanıcı akışı kesilmez.
        _ = await AVCaptureDevice.requestAccess(for: .audio)
    }

    private static func makeRecordingURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(CameraConstants.Video.fileExtension)
    }
}
