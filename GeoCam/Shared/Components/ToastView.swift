//
//  ToastView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Kısa süreli, glass görünümlü bilgilendirme balonu.
struct ToastView: View {
    let systemImage: String
    let message: String

    var body: some View {
        Label(message, systemImage: systemImage)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, LayoutConstants.Spacing.medium)
            .padding(.vertical, LayoutConstants.Spacing.small)
            .glassCard(cornerRadius: LayoutConstants.CornerRadius.large)
            .accessibilityElement(children: .combine)
    }
}

#Preview {
    ToastView(systemImage: "checkmark.circle.fill", message: "Fotoğraf kaydedildi")
}
