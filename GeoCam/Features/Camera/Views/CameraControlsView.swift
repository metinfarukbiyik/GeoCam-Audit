//
//  CameraControlsView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Mod seçici, deklanşör, flaş ve kamera değiştirme kontrollerini barındıran alt bar.
struct CameraControlsView: View {
    let captureMode: CaptureMode
    let flashMode: CameraFlashMode
    let isShutterLocked: Bool
    let isRecording: Bool
    let pendingProcessingCount: Int
    let lastCaptureThumbnail: UIImage?
    let zoomFactor: CameraZoomFactor
    let availableZoomFactors: [CameraZoomFactor]
    let onCapture: () -> Void
    let onSelectMode: (CaptureMode) -> Void
    let onToggleFlash: () -> Void
    let onSwitchCamera: () -> Void
    let onOpenPhotos: () -> Void
    let onSelectZoom: (CameraZoomFactor) -> Void

    var body: some View {
        VStack(spacing: LayoutConstants.Spacing.medium) {
            if availableZoomFactors.count > 1 {
                CameraZoomPicker(
                    selection: zoomFactor,
                    availableFactors: availableZoomFactors,
                    onSelect: onSelectZoom
                )
            }

            CaptureModePicker(
                selection: captureMode,
                isEnabled: !isRecording,
                onSelect: onSelectMode
            )

            // Yan gruplar eşit genişlik alarak deklanşörün ortada kalmasını sağlar.
            HStack(spacing: 0) {
                leadingControls
                    .frame(maxWidth: .infinity, alignment: .leading)

                CaptureButtonView(
                    mode: captureMode,
                    isBusy: isShutterLocked,
                    isRecording: isRecording,
                    action: onCapture
                )

                switchCameraButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.title2)
            .foregroundStyle(.white)
            .padding(.horizontal, LayoutConstants.Spacing.large)
        }
    }

    private var leadingControls: some View {
        HStack(spacing: LayoutConstants.Spacing.medium) {
            ZStack(alignment: .topTrailing) {
                CaptureThumbnailButton(image: lastCaptureThumbnail, action: onOpenPhotos)

                if pendingProcessingCount > 0 {
                    Text(pendingProcessingCount > 9 ? "9+" : "\(pendingProcessingCount)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.yellow, in: Capsule())
                        .offset(x: 6, y: -6)
                        .accessibilityLabel("\(pendingProcessingCount) fotoğraf işleniyor")
                }
            }

            Button(action: onToggleFlash) {
                Image(systemName: flashMode.systemImageName)
            }
            .accessibilityLabel(captureMode == .video ? "Işık modu" : "Flaş modu")
        }
    }

    private var switchCameraButton: some View {
        Button(action: onSwitchCamera) {
            Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
        }
        .accessibilityLabel("Kamerayı değiştir")
        .disabled(isRecording)
        .opacity(isRecording ? 0.4 : 1)
    }
}

#Preview {
    CameraControlsView(
        captureMode: .photo,
        flashMode: .auto,
        isShutterLocked: false,
        isRecording: false,
        pendingProcessingCount: 2,
        lastCaptureThumbnail: nil,
        zoomFactor: .wide,
        availableZoomFactors: CameraZoomFactor.allCases,
        onCapture: {},
        onSelectMode: { _ in },
        onToggleFlash: {},
        onSwitchCamera: {},
        onOpenPhotos: {},
        onSelectZoom: { _ in }
    )
    .padding()
    .background(.black)
}
