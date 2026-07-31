//
//  CaptureModePicker.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Fotoğraf ve video modları arasında geçiş sağlayan seçici.
struct CaptureModePicker: View {

    let selection: CaptureMode
    let isEnabled: Bool
    let onSelect: (CaptureMode) -> Void

    var body: some View {
        HStack(spacing: LayoutConstants.Spacing.small) {
            ForEach(CaptureMode.allCases) { mode in
                Button {
                    onSelect(mode)
                } label: {
                    Text(mode.title)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, LayoutConstants.Spacing.medium)
                        .padding(.vertical, LayoutConstants.Spacing.small)
                        .background(background(for: mode))
                        .foregroundStyle(mode == selection ? .black : .white)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(mode == selection ? [.isSelected] : [])
            }
        }
        .padding(LayoutConstants.Spacing.extraSmall)
        .glassCard(cornerRadius: LayoutConstants.CornerRadius.large)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }

    @ViewBuilder
    private func background(for mode: CaptureMode) -> some View {
        let shape = Capsule(style: .continuous)

        if mode == selection {
            shape.fill(.white)
        } else {
            shape.fill(.clear)
        }
    }
}

#Preview {
    CaptureModePicker(selection: .photo, isEnabled: true, onSelect: { _ in })
        .padding()
        .background(.black)
}
