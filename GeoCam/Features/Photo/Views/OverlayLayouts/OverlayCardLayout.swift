//
//  OverlayCardLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Klasik kart tasarımı: adres kendi bloğunda sarılır, diğer alanlar satır satır gösterilir.
struct OverlayCardLayout: View {
    let model: OverlayDisplayModel
    let chromeStyle: OverlayChromeStyle
    let maxWidth: CGFloat

    private var innerWidth: CGFloat {
        max(maxWidth - LayoutConstants.Spacing.medium * 2, 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.extraSmall) {
            if let branding = model.branding {
                OverlayBrandingHeaderView(
                    branding: branding,
                    textSize: model.textSize,
                    maxWidth: innerWidth
                )

                Divider()
                    .overlay(.white.opacity(0.25))
                    .padding(.vertical, LayoutConstants.Spacing.extraSmall)
            }

            addressBlock

            ForEach(model.detailRows) { row in
                InfoRowView(
                    systemImage: row.systemImage,
                    title: row.title,
                    value: row.value,
                    tone: .onDark,
                    valueTint: row.tint
                )
            }
        }
        .padding(LayoutConstants.Spacing.medium)
        .frame(width: maxWidth, alignment: .leading)
        .overlayChrome(chromeStyle)
    }

    @ViewBuilder
    private var addressBlock: some View {
        if let address = model.addressText {
            VStack(alignment: .leading, spacing: LayoutConstants.Spacing.extraSmall) {
                HStack(spacing: LayoutConstants.Spacing.small) {
                    Image(systemName: "mappin.and.ellipse")
                        .imageScale(.medium)
                        .accessibilityHidden(true)

                    Text(model.addressTitle)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Text(address)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)
            }
            .accessibilityElement(children: .combine)
        }
    }
}
