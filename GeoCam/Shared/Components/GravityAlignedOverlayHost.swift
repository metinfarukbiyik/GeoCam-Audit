//
//  GravityAlignedOverlayHost.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Arayüz portrede kalsa bile katmanı cihaz yönüne göre döndürür ve boyutu buna göre ayarlar.
struct GravityAlignedOverlayHost<Content: View>: View {

    let deviceOrientation: DeviceDisplayOrientation
    let position: OverlayPosition
    let textSize: OverlayTextSize
    let onPositionChange: (OverlayPosition) -> Void
    let onTextSizeChange: (OverlayTextSize) -> Void
    @ViewBuilder let content: (_ maxWidth: CGFloat) -> Content

    var body: some View {
        GeometryReader { proxy in
            let frameSize = proxy.size
            let interfaceIsLandscape = frameSize.width > frameSize.height
            let alignsToGravity = !interfaceIsLandscape && deviceOrientation != .portrait
            let workSize = alignsToGravity
                ? CGSize(width: frameSize.height, height: frameSize.width)
                : frameSize
            let degrees = alignsToGravity ? deviceOrientation.gravityAlignmentDegrees : 0

            DraggableOverlayPositioner(
                position: position,
                textSize: textSize,
                onPositionChange: onPositionChange,
                onTextSizeChange: onTextSizeChange,
                content: content
            )
            .frame(width: workSize.width, height: workSize.height)
            .rotationEffect(.degrees(degrees))
            .frame(width: frameSize.width, height: frameSize.height)
            // Hit-test alanı yalnızca önizleme çerçevesi; layout taşması olmasın.
            .allowsHitTesting(true)
            .animation(
                .easeInOut(duration: AppConstants.Animation.standard),
                value: deviceOrientation
            )
        }
        // GeometryReader kardeş önizlemeyi küçültmesin; verilen çerçeveyi doldursun.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var position = OverlayPosition.default
    @Previewable @State var textSize = OverlayTextSize.medium

    return GravityAlignedOverlayHost(
        deviceOrientation: .landscapeLeft,
        position: position,
        textSize: textSize,
        onPositionChange: { position = $0 },
        onTextSizeChange: { textSize = $0 }
    ) { maxWidth in
        Text("Besirli, Trabzon")
            .padding()
            .frame(width: maxWidth, alignment: .leading)
            .background(.gray.opacity(0.5))
    }
    .frame(width: 390, height: 844)
    .background(.black)
}
