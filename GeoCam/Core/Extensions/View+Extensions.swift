//
//  View+Extensions.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

extension View {
    /// Glassmorphism arka planı uygular.
    func glassCard(cornerRadius: CGFloat = LayoutConstants.CornerRadius.medium) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }

    /// Hata bilgisini standart Apple alert'i olarak sunar.
    func errorAlert(_ item: Binding<ErrorAlertItem?>) -> some View {
        alert(
            item.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented { item.wrappedValue = nil }
                }
            ),
            presenting: item.wrappedValue
        ) { _ in
            Button("Tamam", role: .cancel) {}
        } message: { alertItem in
            if let message = alertItem.message {
                Text(message)
            }
        }
    }
}
