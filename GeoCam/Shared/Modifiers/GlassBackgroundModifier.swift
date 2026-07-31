//
//  GlassBackgroundModifier.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Yarı saydam, yuvarlatılmış köşeli glassmorphism arka planı.
struct GlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
    }
}
