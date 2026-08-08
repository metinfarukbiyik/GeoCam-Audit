//
//  OverlayCompactLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Dar alan tasarımı: tüm metinler verilen genişlik içinde satır atlar.
struct OverlayCompactLayout: View {
    let model: OverlayDisplayModel
    let chromeStyle: OverlayChromeStyle
    let maxWidth: CGFloat

    private var innerWidth: CGFloat {
        max(maxWidth - LayoutConstants.Spacing.medium * 2, 0)
    }

    private var addressTextWidth: CGFloat {
        // Simge (~14) + boşluk düşülür; metin bu genişlikte satır atlar.
        max(innerWidth - 22, 0)
    }

    var body: some View {
        VStack(alignment: model.alignment.stackAlignment, spacing: LayoutConstants.Spacing.extraSmall) {
            if let branding = model.branding {
                OverlayBrandingHeaderView(
                    branding: branding,
                    textSize: model.textSize,
                    alignment: model.alignment,
                    maxWidth: innerWidth
                )
            }

            if let address = model.addressText {
                OverlayMarkedRow(alignment: model.alignment) {
                    Image(systemName: "mappin.and.ellipse")
                        .frame(width: 14, alignment: .center)
                        .accessibilityHidden(true)
                } content: {
                    Text(address)
                        .fontWeight(.medium)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: addressTextWidth, alignment: model.alignment.frameAlignment)
                }
                .frame(width: innerWidth, alignment: model.alignment.frameAlignment)
            }

            ForEach(model.detailRows) { row in
                Text(row.displayText)
                    .foregroundStyle(row.tint ?? .white.opacity(0.9))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: model.alignment.frameAlignment)
            }
        }
        .padding(.horizontal, LayoutConstants.Spacing.medium)
        .padding(.vertical, LayoutConstants.Spacing.small)
        .frame(width: maxWidth, alignment: model.alignment.frameAlignment)
        .background {
            chromeBackground
        }
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous))
    }

    @ViewBuilder
    private var chromeBackground: some View {
        let shape = RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous)

        switch chromeStyle {
        case .live:
            shape.fill(.ultraThinMaterial)
        case .stamped:
            shape.fill(.black.opacity(OverlayConstants.stampedBackgroundOpacity))
        }
    }
}
