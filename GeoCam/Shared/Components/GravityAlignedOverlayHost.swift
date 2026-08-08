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
    let corner: OverlayCorner
    let verticalPosition: CGFloat
    let scale: CGFloat
    let onPlacementChange: (_ corner: OverlayCorner, _ verticalPosition: CGFloat) -> Void
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
                corner: corner,
                verticalPosition: verticalPosition,
                scale: scale,
                onPlacementChange: onPlacementChange,
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    @Previewable @State var corner = OverlayCorner.trailing
    @Previewable @State var vertical: CGFloat = 0.8
    @Previewable @State var scale: CGFloat = 0.7

    return GravityAlignedOverlayHost(
        deviceOrientation: .landscapeLeft,
        corner: corner,
        verticalPosition: vertical,
        scale: scale,
        onPlacementChange: { corner = $0; vertical = $1 },
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
