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
    let alignment: OverlayHorizontalAlignment
    let scale: CGFloat
    let onPositionChange: (OverlayPosition) -> Void
    let onScaleChange: (CGFloat) -> Void
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
                alignment: alignment,
                scale: scale,
                onPositionChange: onPositionChange,
                onScaleChange: onScaleChange,
                content: content
            )
            .frame(width: workSize.width, height: workSize.height)
            .rotationEffect(.degrees(degrees))
            .frame(width: frameSize.width, height: frameSize.height)
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
    @Previewable @State var scale: CGFloat = 0.7

    return GravityAlignedOverlayHost(
        deviceOrientation: .landscapeLeft,
        position: position,
        alignment: .trailing,
        scale: scale,
        onPositionChange: { position = $0 },
        onScaleChange: { scale = $0 }
    ) { maxWidth in
        Text("Besirli, Trabzon")
            .padding()
            .frame(width: maxWidth, alignment: .leading)
            .background(.gray.opacity(0.5))
    }
    .frame(width: 390, height: 844)
    .background(.black)
}
