//
//  InfoRowView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Simge + etiket + değer düzeninde bilgi satırı.
/// Değer sutunu esnek genişliktedir; uzun koordinatlar satır atlar.
struct InfoRowView: View {
    let systemImage: String
    let title: String
    let value: String
    var tone: Tone = .standard
    var valueTint: Color?

    enum Tone {
        case standard
        case onDark
    }

    var body: some View {
        HStack(alignment: .top, spacing: LayoutConstants.Spacing.small) {
            Image(systemName: systemImage)
                .imageScale(.medium)
                .accessibilityHidden(true)

            Text(title)
                .foregroundStyle(titleColor)
                .fixedSize(horizontal: true, vertical: false)

            Group {
                if let valueTint {
                    Text(value).foregroundStyle(valueTint)
                } else {
                    Text(value)
                }
            }
            .fontWeight(.medium)
            .multilineTextAlignment(.trailing)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            .layoutPriority(-1)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var titleColor: Color {
        switch tone {
        case .standard: .secondary
        case .onDark: .white.opacity(0.75)
        }
    }
}

#Preview {
    VStack {
        InfoRowView(
            systemImage: "globe",
            title: "Koordinat",
            value: "40,99386, 39,69464"
        )
        .frame(width: 280)
    }
    .padding()
}
