//
//  OverlayChromeBackground.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Katman tasarımlarının ortak arka plan stili.
/// Canlı önizlemede materyal, fotoğrafa basılırken yarı saydam siyah kullanılır.
struct OverlayChromeBackground: ViewModifier {
    let style: OverlayChromeStyle
    var cornerRadius: CGFloat = LayoutConstants.CornerRadius.medium

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content
            .background {
                switch style {
                case .live:
                    shape.fill(.ultraThinMaterial)
                case .stamped:
                    shape.fill(.black.opacity(OverlayConstants.stampedBackgroundOpacity))
                }
            }
            // Materyalin kutu dışına taşmasını engeller.
            .compositingGroup()
            .clipShape(shape)
    }
}

extension View {
    func overlayChrome(
        _ style: OverlayChromeStyle,
        cornerRadius: CGFloat = LayoutConstants.CornerRadius.medium
    ) -> some View {
        modifier(OverlayChromeBackground(style: style, cornerRadius: cornerRadius))
    }
}
