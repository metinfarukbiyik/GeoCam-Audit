//
//  ProcessingOverlayView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Uzun süren bir işlem boyunca ekranı kilitleyen bilgilendirme katmanı.
struct ProcessingOverlayView: View {

    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(LayoutConstants.SideMenu.backdropOpacity)

            VStack(spacing: LayoutConstants.Spacing.medium) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)

                Text(message)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
            }
            .padding(LayoutConstants.Spacing.large)
            .glassCard()
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

#Preview {
    ZStack {
        Color.gray
        ProcessingOverlayView(message: "Video işleniyor…")
    }
}
