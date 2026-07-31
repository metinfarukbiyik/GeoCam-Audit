//
//  OverlayPosterLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Alt şerit tasarımı: adres büyük başlık, detaylar ayrı satırlarda.
struct OverlayPosterLayout: View {
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
            }

            if let address = model.addressText {
                Text(address)
                    .font(.system(size: model.textSize.titlePointSize, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)
            }

            ForEach(model.detailRows) { row in
                Text(row.displayText)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)
            }
        }
        .padding(LayoutConstants.Spacing.medium)
        .frame(width: maxWidth, alignment: .leading)
        .background { posterBackground }
        .clipped()
    }

    @ViewBuilder
    private var posterBackground: some View {
        switch chromeStyle {
        case .live:
            LinearGradient(
                colors: [.black.opacity(0.05), .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .stamped:
            LinearGradient(
                colors: [.clear, .black.opacity(OverlayConstants.stampedBackgroundOpacity)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
