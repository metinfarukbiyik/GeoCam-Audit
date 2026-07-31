//
//  CaptureButtonView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Deklanşör düğmesi. Video modunda kayıt durumunu da yansıtır.
struct CaptureButtonView: View {
    @Environment(\.appLanguage) private var language

    let mode: CaptureMode
    let isBusy: Bool
    let isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(.white, lineWidth: LayoutConstants.CaptureButton.borderWidth)
                    .frame(
                        width: LayoutConstants.CaptureButton.outerDiameter,
                        height: LayoutConstants.CaptureButton.outerDiameter
                    )

                inner
                    .opacity(isBusy ? 0.4 : 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isBusy)
        .animation(.easeInOut(duration: AppConstants.Animation.quick), value: isRecording)
        .accessibilityLabel(accessibilityLabel)
    }

    /// Kayıt sırasında daire, durdurma anlamına gelen kareye dönüşür.
    @ViewBuilder
    private var inner: some View {
        let diameter = LayoutConstants.CaptureButton.innerDiameter

        if isRecording {
            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous)
                .fill(.red)
                .frame(width: diameter / 2, height: diameter / 2)
        } else {
            Circle()
                .fill(mode == .video ? .red : .white)
                .frame(width: diameter, height: diameter)
        }
    }

    private var accessibilityLabel: String {
        switch (mode, isRecording) {
        case (.photo, _): language.t(.capturePhotoAccessibility)
        case (.video, false): language.t(.captureRecordStart)
        case (.video, true): language.t(.captureRecordStop)
        }
    }
}

#Preview {
    HStack(spacing: LayoutConstants.Spacing.large) {
        CaptureButtonView(mode: .photo, isBusy: false, isRecording: false, action: {})
        CaptureButtonView(mode: .video, isBusy: false, isRecording: false, action: {})
        CaptureButtonView(mode: .video, isBusy: false, isRecording: true, action: {})
    }
    .padding()
    .background(.black)
}
