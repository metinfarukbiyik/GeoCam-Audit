//
//  OverlayMinimalLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Arka plansız sade tasarım: yalnızca gölgeli metin satırları.
struct OverlayMinimalLayout: View {
    let model: OverlayDisplayModel
    let maxWidth: CGFloat

    private var innerWidth: CGFloat {
        max(maxWidth - LayoutConstants.Spacing.small * 2, 0)
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
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)
            }

            ForEach(model.detailRows) { row in
                Text(row.showsInlineLabel ? row.displayText : "\(row.title): \(row.value)")
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)
            }
        }
        .padding(LayoutConstants.Spacing.small)
        .frame(width: maxWidth, alignment: .leading)
        .shadow(
            color: .black.opacity(OverlayConstants.MinimalShadow.opacity),
            radius: OverlayConstants.MinimalShadow.radius,
            x: 0,
            y: OverlayConstants.MinimalShadow.yOffset
        )
    }
}
