//
//  CameraViewModel.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import Observation
import OSLog
import UIKit

/// Kamera ekranının durumunu ve kullanıcı aksiyonlarını yönetir.
/// Çekilen içerik önizleme beklemeden doğrudan kitaplığa kaydedilir.
@MainActor
@Observable
final class CameraViewModel {

    private let cameraManager: any CameraManaging
    private let photoLibraryService: any PhotoLibraryServicing
    private let metadataProvider: any PhotoMetadataProviding
    private let overlayRenderer: any OverlayRendering
    private let videoOverlayRenderer: any VideoOverlayRendering
    private let settingsStore: SettingsStore
    private let brandingAssetStore: BrandingAssetStore
    private let processingQueue = CaptureProcessingQueue()

    private(set) var permissionStatus: PermissionStatus = .notDetermined
    private(set) var isCapturing = false
    /// Kayıt bittikten sonra katmanın videoya işlendiği süre.
    private(set) var isProcessingVideo = false
    /// Arka planda damga/kayıt bekleyen veya işlenen fotoğraf sayısı.
    private(set) var pendingProcessingCount = 0
    /// Kayıt tamamlandığında gösterilecek bilgilendirme metni.
    private(set) var saveConfirmation: String?
    /// Kontrollerdeki son çekim göstergesi.
    private(set) var lastCaptureThumbnail: UIImage?
    var alertItem: ErrorAlertItem?

    private var isSessionPrepared = false
    /// Kaydın başladığı andaki konum bilgisi; katman bu değerlerle basılır.
    private var recordingMetadata: PhotoMetadata?
    /// Seri kayıtta toplu onay mesajı için sayaç.
    private var savedBatchCount = 0

    var previewLayer: AVCaptureVideoPreviewLayer { cameraManager.previewLayer }
    var flashMode: CameraFlashMode { cameraManager.configuration.flashMode }
    var captureMode: CaptureMode { cameraManager.configuration.captureMode }
    var isSessionRunning: Bool { cameraManager.isSessionRunning }
    var isRecording: Bool { cameraManager.isRecording }
    /// SettingsStore güncellemelerinin kamera ekranına yansıması için sayaç.
    private(set) var settingsRevision = 0

    /// Deklanşör sensör meşgulken veya kuyruk doluyken kilitlenir.
    var isShutterLocked: Bool {
        isCapturing || pendingProcessingCount >= CameraConstants.Capture.maxPendingJobs
    }

    /// İşlenen fotoğraflar varken gösterilecek durum metni.
    var processingStatusMessage: String? {
        guard pendingProcessingCount > 0 else { return nil }

        let language = settingsStore.settings.appLanguage
        if pendingProcessingCount == 1 {
            return language.t(.captureProcessingOne)
        }

        return language.t(.captureProcessingMany, pendingProcessingCount)
    }

    var overlaySettings: OverlaySettings {
        // Revision okunmazsa Observation, store değişimini ViewModel üzerinden yaymaz.
        _ = settingsRevision
        return settingsStore.settings
    }

    var aspectRatio: CameraAspectRatio { overlaySettings.aspectRatio }
    var zoomFactor: CameraZoomFactor { cameraManager.zoomFactor }
    var availableZoomFactors: [CameraZoomFactor] { cameraManager.availableZoomFactors }
    var deviceZoomFactor: CGFloat { cameraManager.deviceZoomFactor }

    init(
        cameraManager: any CameraManaging,
        photoLibraryService: any PhotoLibraryServicing,
        metadataProvider: any PhotoMetadataProviding,
        overlayRenderer: any OverlayRendering,
        videoOverlayRenderer: any VideoOverlayRendering,
        settingsStore: SettingsStore,
        brandingAssetStore: BrandingAssetStore
    ) {
        self.cameraManager = cameraManager
        self.photoLibraryService = photoLibraryService
        self.metadataProvider = metadataProvider
        self.overlayRenderer = overlayRenderer
        self.videoOverlayRenderer = videoOverlayRenderer
        self.settingsStore = settingsStore
        self.brandingAssetStore = brandingAssetStore
    }

    // MARK: - Lifecycle

    func start() async {
        permissionStatus = await cameraManager.requestPermission()
        guard permissionStatus.isAuthorized else { return }

        if !isSessionPrepared {
            do {
                try await cameraManager.prepareSession()
                isSessionPrepared = true
            } catch {
                present(error)
                return
            }
        }

        await cameraManager.startSession()
    }

    func stop() async {
        if isRecording {
            _ = try? await cameraManager.stopRecording()
        }

        await cameraManager.stopSession()
    }

    // MARK: - Actions

    /// Deklanşör davranışı seçili moda göre değişir.
    func triggerCapture() async {
        switch captureMode {
        case .photo: await capturePhoto()
        case .video: await toggleRecording()
        }
    }

    func setCaptureMode(_ mode: CaptureMode) async {
        guard !isRecording else { return }

        do {
            try await cameraManager.setCaptureMode(mode)
        } catch {
            present(error)
        }
    }

    func acknowledgeSave() {
        saveConfirmation = nil
    }

    /// Kullanıcı bilgi katmanını sürüklediğinde yeni konum kalıcı hale getirilir.
    func updateOverlayPosition(_ position: OverlayPosition) {
        let sanitized = position.sanitized()
        var settings = settingsStore.settings
        guard settings.position != sanitized else { return }

        settings.position = sanitized
        settingsStore.update(settings)
        settingsRevision += 1
    }

    /// Çift parmak jesti ile bilgi katmanının tamamı küçültülüp büyütülür.
    func updateOverlayScale(_ scale: CGFloat) {
        let clamped = OverlayConstants.Scale.clamped(scale)
        var settings = settingsStore.settings
        guard settings.resolvedScale != clamped else { return }

        settings.overlayScale = clamped
        settingsStore.update(settings)
        settingsRevision += 1
    }

    func toggleFlashMode() {
        cameraManager.setFlashMode(flashMode.next)
    }

    func switchCamera() async {
        do {
            try await cameraManager.switchCamera()
        } catch {
            present(error)
        }
    }

    func setZoomFactor(_ factor: CameraZoomFactor) async {
        await cameraManager.setZoomFactor(factor)
    }

    func setDeviceZoomFactor(_ factor: CGFloat) async {
        await cameraManager.setDeviceZoomFactor(factor)
    }

    func snapZoomToNearestFactor() async {
        await cameraManager.snapZoomToNearestFactor()
    }

    // MARK: - Private

    /// Sensör çekimi bitince deklanşör açılır; damga/kayıt sınırlı kuyrukta yürür.
    private func capturePhoto() async {
        guard !isCapturing else { return }

        if pendingProcessingCount >= CameraConstants.Capture.maxPendingJobs {
            saveConfirmation = settingsStore.settings.appLanguage.t(.captureQueueFull)
            return
        }

        isCapturing = true

        do {
            let imageData = try await cameraManager.capturePhoto()
            let photo = CapturedPhoto(
                originalData: imageData,
                metadata: metadataProvider.currentMetadata()
            )
            isCapturing = false

            // Anında küçük önizleme; tam damga bitmeden UI güncellenir.
            publishQuickThumbnail(from: photo.originalData)

            let settings = settingsStore.settings
            let branding = currentBranding()
            pendingProcessingCount += 1

            await processingQueue.enqueue { [weak self] in
                await self?.processAndSave(
                    photo: photo,
                    settings: settings,
                    branding: branding
                )
            }
        } catch {
            isCapturing = false
            present(error)
        }
    }

    private func publishQuickThumbnail(from imageData: Data) {
        Task {
            guard let thumbnail = await ThumbnailFactory.makeThumbnail(
                from: imageData,
                maxPixelSize: LayoutConstants.Thumbnail.maxPixelDimension
            ) else { return }

            lastCaptureThumbnail = thumbnail
        }
    }

    private func processAndSave(
        photo: CapturedPhoto,
        settings: OverlaySettings,
        branding: OverlayBranding?
    ) async {
        defer { finishProcessingJob() }

        do {
            let renderedData = try await overlayRenderer.render(
                photo: photo,
                settings: settings,
                branding: branding
            )

            try await photoLibraryService.save(imageData: renderedData)

            // Damgasız kopya da seçili çerçeve oranına (4:3 / 9:16) kırpılır.
            if settings.savesOriginalPhoto {
                let plainData = try await overlayRenderer.renderPlain(
                    photo: photo,
                    settings: settings
                )
                try await photoLibraryService.save(imageData: plainData)
            }

            // Damgalı sonuç hazırsa thumbnail’i güncelle (ham önizlemenin üzerine).
            if let stampedThumbnail = await ThumbnailFactory.makeThumbnail(
                from: renderedData,
                maxPixelSize: LayoutConstants.Thumbnail.maxPixelDimension
            ) {
                lastCaptureThumbnail = stampedThumbnail
            }

            savedBatchCount += 1
        } catch {
            present(error)
        }
    }

    private func finishProcessingJob() {
        pendingProcessingCount = max(0, pendingProcessingCount - 1)

        guard pendingProcessingCount == 0, savedBatchCount > 0 else { return }

        let language = settingsStore.settings.appLanguage
        saveConfirmation = savedBatchCount == 1
            ? language.t(.capturePhotoSaved)
            : language.t(.capturePhotosSaved, savedBatchCount)
        savedBatchCount = 0
    }

    private func toggleRecording() async {
        guard !isCapturing else { return }

        isCapturing = true
        defer { isCapturing = false }

        do {
            if isRecording {
                try await finishRecording(at: try await cameraManager.stopRecording())
            } else {
                try await cameraManager.startRecording()
                recordingMetadata = metadataProvider.currentMetadata()
            }
        } catch {
            present(error)
        }
    }

    private func finishRecording(at sourceURL: URL) async throws {
        let metadata = recordingMetadata ?? metadataProvider.currentMetadata()
        recordingMetadata = nil

        isProcessingVideo = true
        defer { isProcessingVideo = false }

        let outputURL = await stamped(sourceURL, metadata: metadata)
        // Küçük görsel kaydetmeden önce üretilir; kitaplık servisi dosyayı taşıdıktan sonra siler.
        let thumbnail = await ThumbnailFactory.makeThumbnail(
            fromVideoAt: outputURL,
            maxPixelSize: LayoutConstants.Thumbnail.maxPixelDimension
        )

        try await photoLibraryService.save(videoAt: outputURL)
        lastCaptureThumbnail = thumbnail
        saveConfirmation = settingsStore.settings.appLanguage.t(.captureVideoSaved)
    }

    /// Katman işlenemezse kayıt kaybolmasın diye ham video kaydedilir.
    /// Filigran zorunlu olduğu için boş katmanda bile video işlenir.
    private func stamped(_ sourceURL: URL, metadata: PhotoMetadata) async -> URL {
        let branding = currentBranding()
        let settings = settingsStore.settings

        guard settings.appliesAppWatermark
            || !settings.enabledFields.isEmpty
            || branding != nil
        else { return sourceURL }

        do {
            let renderedURL = try await videoOverlayRenderer.render(
                videoAt: sourceURL,
                metadata: metadata,
                settings: settings,
                branding: branding
            )

            try? FileManager.default.removeItemIfExists(at: sourceURL)
            return renderedURL
        } catch {
            AppLogger.camera.error("Video katmanı işlenemedi: \(String(describing: error), privacy: .public)")
            return sourceURL
        }
    }

    /// Marka katmanı yalnızca kullanıcı açtıysa ve gösterilecek bir içerik varsa üretilir.
    private func currentBranding() -> OverlayBranding? {
        OverlayBranding.make(
            settings: settingsStore.settings,
            logo: brandingAssetStore.logo
        )
    }

    private func present(_ error: any Error) {
        AppLogger.camera.error("\(String(describing: error), privacy: .public)")

        let language = settingsStore.settings.appLanguage

        guard let presentable = error as? any UserPresentableError else {
            alertItem = ErrorAlertItem(CameraError.captureFailed, language: language)
            return
        }

        alertItem = ErrorAlertItem(presentable, language: language)
    }
}
