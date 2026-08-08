//
//  InfoRowView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Simge + etiket + değer düzeninde bilgi satırı.
/// Değer sutunu esnek genişliktedir; uzun koordinatlar satır atlar.
/// Sağa yaslı katmanda sıralama aynalanır: değer solda, simge sağda kalır.
struct InfoRowView: View {
    let systemImage: String
    let title: String
    let value: String
    var alignment: OverlayHorizontalAlignment = .leading
    var tone: Tone = .standard
    var valueTint: Color?

    enum Tone {
        case standard
        case onDark
    }

    var body: some View {
        HStack(alignment: .top, spacing: LayoutConstants.Spacing.small) {
            switch alignment {
            case .leading:
                markView
                titleView
                valueView
            case .trailing:
                valueView
                titleView
                markView
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment.frameAlignment)
        .accessibilityElement(children: .combine)
    }

    private var markView: some View {
        Image(systemName: systemImage)
            .imageScale(.medium)
            .accessibilityHidden(true)
    }

    private var titleView: some View {
        Text(title)
            .foregroundStyle(titleColor)
            .fixedSize(horizontal: true, vertical: false)
    }

    private var valueView: some View {
        Group {
            if let valueTint {
                Text(value).foregroundStyle(valueTint)
            } else {
                Text(value)
            }
        }
        .fontWeight(.medium)
        // Değer, etiketin karşı tarafına yaslanır.
        .multilineTextAlignment(alignment.opposite.textAlignment)
        .lineLimit(2)
        .minimumScaleFactor(0.75)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment.opposite.frameAlignment)
        .layoutPriority(-1)
    }

    private var titleColor: Color {
        switch tone {
        case .standard: .secondary
        case .onDark: .white.opacity(0.75)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(OverlayHorizontalAlignment.allCases) { alignment in
            InfoRowView(
                systemImage: "globe",
                title: "Koordinat",
                value: "Enlem 41°00'29.7\"N",
                alignment: alignment
            )
            .frame(width: 280)
        }
    }
    .padding()
}
