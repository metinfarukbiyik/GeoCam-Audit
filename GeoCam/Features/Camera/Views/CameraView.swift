//
//  CameraView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Uygulamanın ana ekranı: oranına göre çerçeveli önizleme, bilgi katmanı ve yüzen kontroller.
struct CameraView: View {

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(AppDependencies.self) private var dependencies

    @State private var viewModel: CameraViewModel
    @State private var locationViewModel: LocationViewModel
    @State private var isShutterFlashVisible = false
    @State private var isJobInfoPresented = false
    /// Pinch başlangıcındaki cihaz zoom değeri; jest boyunca çarpan olarak kullanılır.
    @State private var pinchBaselineZoom: CGFloat?

    private let onOpenMenu: () -> Void

    init(
        viewModel: CameraViewModel,
        locationViewModel: LocationViewModel,
        onOpenMenu: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _locationViewModel = State(initialValue: locationViewModel)
        self.onOpenMenu = onOpenMenu
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.permissionStatus.requiresSettingsRedirect {
                cameraPermissionPlaceholder
            } else {
                cameraContent
            }
        }
        .toolbar { cameraToolbar }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $isJobInfoPresented) {
            JobInfoSheet(
                settings: jobInfoSettingsBinding,
                onDismiss: { isJobInfoPresented = false }
            )
        }
        .errorAlert($viewModel.alertItem)
        .task { await startServices() }
        .onChange(of: scenePhase) { _, newPhase in
            Task { await handle(scenePhase: newPhase) }
        }
    }

    private var jobInfoSettingsBinding: Binding<OverlaySettings> {
        Binding(
            get: { dependencies.settingsStore.settings },
            set: { dependencies.settingsStore.update($0) }
        )
    }

    // MARK: - Content

    private var cameraContent: some View {
        ZStack(alignment: .bottom) {
            framedPreview

            floatingControls

            if viewModel.isProcessingVideo {
                ProcessingOverlayView(message: "Video işleniyor…")
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: AppConstants.Animation.standard),
            value: viewModel.isProcessingVideo
        )
    }

    /// 9:16 tam ekran (şarj çubuğundan alta); 4:3 küçültülmüş çerçeve ile çekim alanı net görünür.
    private var framedPreview: some View {
        GeometryReader { proxy in
            let captureFrame = Self.captureFrame(
                for: viewModel.aspectRatio,
                in: proxy.size
            )

            ZStack {
                Color.black

                ZStack {
                    CameraPreviewView(previewLayer: viewModel.previewLayer)
                        .simultaneousGesture(cameraPinchZoomGesture)

                    shutterFlash

                    infoOverlay

                    if viewModel.aspectRatio == .standard {
                        Rectangle()
                            .strokeBorder(.white.opacity(0.35), lineWidth: 1)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: captureFrame.width, height: captureFrame.height)
                .clipped()
                .position(x: captureFrame.midX, y: captureFrame.midY)
            }
        }
        .ignoresSafeArea()
        .animation(
            .easeInOut(duration: AppConstants.Animation.standard),
            value: viewModel.aspectRatio
        )
    }

    private var cameraPinchZoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { magnification in
                if pinchBaselineZoom == nil {
                    pinchBaselineZoom = viewModel.deviceZoomFactor
                }

                let baseline = pinchBaselineZoom ?? viewModel.deviceZoomFactor
                Task { await viewModel.setDeviceZoomFactor(baseline * magnification) }
            }
            .onEnded { _ in
                pinchBaselineZoom = nil
                Task { await viewModel.snapZoomToNearestFactor() }
            }
    }

    private var infoOverlay: some View {
        let settings = dependencies.settingsStore.settings
        let branding = OverlayBranding.make(
            settings: settings,
            logo: dependencies.brandingAssetStore.logo
        )

        return DraggableOverlayPositioner(
            position: settings.position,
            textSize: settings.textSize,
            onPositionChange: viewModel.updateOverlayPosition,
            onTextSizeChange: viewModel.updateOverlayTextSize
        ) { maxWidth in
            LocationStatusView(
                viewModel: locationViewModel,
                settings: settings,
                branding: branding,
                maxWidth: maxWidth,
                onOpenSettings: openAppSettings
            )
        }
        .allowsHitTesting(true)
    }

    private var floatingControls: some View {
        VStack(spacing: LayoutConstants.Spacing.medium) {
            if let message = viewModel.saveConfirmation {
                ToastView(systemImage: "checkmark.circle.fill", message: message)
                    .transition(.opacity.combined(with: .scale))
            } else if let processing = viewModel.processingStatusMessage {
                ToastView(systemImage: "arrow.triangle.2.circlepath", message: processing)
                    .transition(.opacity.combined(with: .scale))
            }

            CameraControlsView(
                captureMode: viewModel.captureMode,
                flashMode: viewModel.flashMode,
                isShutterLocked: viewModel.isShutterLocked,
                isRecording: viewModel.isRecording,
                pendingProcessingCount: viewModel.pendingProcessingCount,
                lastCaptureThumbnail: viewModel.lastCaptureThumbnail,
                zoomFactor: viewModel.zoomFactor,
                availableZoomFactors: viewModel.availableZoomFactors,
                onCapture: capture,
                onSelectMode: { mode in Task { await viewModel.setCaptureMode(mode) } },
                onToggleFlash: viewModel.toggleFlashMode,
                onSwitchCamera: { Task { await viewModel.switchCamera() } },
                onOpenPhotos: openPhotosApp,
                onSelectZoom: { factor in Task { await viewModel.setZoomFactor(factor) } }
            )
        }
        .padding(.vertical, LayoutConstants.Spacing.large)
        .frame(maxWidth: .infinity)
        .background(controlsScrim)
        .animation(.easeInOut(duration: AppConstants.Animation.standard), value: viewModel.saveConfirmation)
        .animation(.easeInOut(duration: AppConstants.Animation.standard), value: viewModel.pendingProcessingCount)
        .task(id: viewModel.saveConfirmation) { await dismissSaveConfirmation() }
    }

    private var controlsScrim: some View {
        LinearGradient(
            colors: [.black.opacity(0), .black.opacity(0.65)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var cameraPermissionPlaceholder: some View {
        PermissionRequestView(
            systemImage: "camera.fill",
            title: "Kamera Erişimi Gerekli",
            message: "Fotoğraf çekebilmek için Ayarlar'dan kamera erişimine izin verin.",
            actionTitle: "Ayarları Aç",
            action: openAppSettings
        )
    }

    private var shutterFlash: some View {
        Color.white
            .opacity(isShutterFlashVisible ? 1 : 0)
            .allowsHitTesting(false)
    }

    @ToolbarContentBuilder
    private var cameraToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onOpenMenu) {
                Image(systemName: "line.3.horizontal")
            }
            .accessibilityLabel("Ayarlar menüsü")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isJobInfoPresented = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "doc.badge.plus")

                    if dependencies.settingsStore.settings.hasJobInfoContent {
                        Circle()
                            .fill(.yellow)
                            .frame(width: 7, height: 7)
                            .offset(x: 3, y: -2)
                    }
                }
            }
            .accessibilityLabel("İş bilgisi")
            .accessibilityHint(
                dependencies.settingsStore.settings.hasJobInfoContent
                    ? "İş bilgisi dolu; düzenlemek için dokunun"
                    : "İş emri veya site kimliği ekle"
            )
        }
    }

    // MARK: - Actions

    private func capture() {
        if viewModel.captureMode == .photo {
            playShutterFlash()
        }

        Task { await viewModel.triggerCapture() }
    }

    private func playShutterFlash() {
        withAnimation(.easeOut(duration: AppConstants.Animation.quick / 2)) {
            isShutterFlashVisible = true
        }
        withAnimation(.easeIn(duration: AppConstants.Animation.quick).delay(AppConstants.Animation.quick / 2)) {
            isShutterFlashVisible = false
        }
    }

    private func dismissSaveConfirmation() async {
        guard viewModel.saveConfirmation != nil else { return }

        try? await Task.sleep(for: .seconds(AppConstants.Feedback.toastDuration))
        viewModel.acknowledgeSave()
    }

    private func startServices() async {
        await viewModel.start()
        await locationViewModel.start()
    }

    private func handle(scenePhase: ScenePhase) async {
        switch scenePhase {
        case .active:
            await startServices()
        case .background, .inactive:
            await viewModel.stop()
            locationViewModel.stop()
        @unknown default:
            break
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }

    private func openPhotosApp() {
        guard let url = AppConstants.ExternalLink.photosApp else { return }
        openURL(url)
    }

    // MARK: - Geometry

    /// 9:16 tam ekran; 4:3 ekrana sığdırılmış çekim çerçevesi.
    private static func captureFrame(for ratio: CameraAspectRatio, in bounds: CGSize) -> CGRect {
        switch ratio {
        case .wide:
            return CGRect(origin: .zero, size: bounds)
        case .standard:
            return aspectFitRect(ratio: ratio.portraitRatio, in: bounds)
        }
    }

    private static func aspectFitRect(ratio: CGFloat, in bounds: CGSize) -> CGRect {
        guard ratio > 0, bounds.width > 0, bounds.height > 0 else {
            return CGRect(origin: .zero, size: bounds)
        }

        let size: CGSize
        if bounds.width / bounds.height > ratio {
            let height = bounds.height
            size = CGSize(width: height * ratio, height: height)
        } else {
            let width = bounds.width
            size = CGSize(width: width, height: width / ratio)
        }

        return CGRect(
            x: (bounds.width - size.width) / 2,
            y: (bounds.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
    }
}

#Preview {
    let dependencies = AppDependencies()
    return NavigationStack {
        CameraView(
            viewModel: dependencies.makeCameraViewModel(),
            locationViewModel: dependencies.makeLocationViewModel(),
            onOpenMenu: {}
        )
    }
    .environment(dependencies)
}
