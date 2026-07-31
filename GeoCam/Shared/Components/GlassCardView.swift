//
//  GlassCardView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// İçeriği glassmorphism bir kart içinde sunan yeniden kullanılabilir kapsayıcı.
struct GlassCardView<Content: View>: View {
    var cornerRadius: CGFloat = LayoutConstants.CornerRadius.medium
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(LayoutConstants.Spacing.medium)
            .glassCard(cornerRadius: cornerRadius)
    }
}

#Preview {
    GlassCardView {
        Text("GeoCam")
    }
    .padding()
}
