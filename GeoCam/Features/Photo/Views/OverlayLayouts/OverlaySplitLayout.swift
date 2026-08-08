//
//  OverlaySplitLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Teknik iki sütun tasarımı: bir yanda kısa etiket, diğer yanda değer.
struct OverlaySplitLayout: View {
    let model: OverlayDisplayModel
    let chromeStyle: OverlayChromeStyle
    let maxWidth: CGFloat

    private var innerWidth: CGFloat {
        max(maxWidth - LayoutConstants.Spacing.medium * 2, 0)
    }

    private var labelWidth: CGFloat {
        max(innerWidth * 0.22, 52)
    }

    private var valueWidth: CGFloat {
        max(innerWidth - labelWidth - LayoutConstants.Spacing.medium, 0)
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
                splitRow(title: model.addressTitle, value: address)
            }

            ForEach(model.detailRows) { row in
                splitRow(title: row.title, value: row.value, tint: row.tint)
            }
        }
        .padding(LayoutConstants.Spacing.medium)
        .frame(width: maxWidth, alignment: model.alignment.frameAlignment)
        .overlayChrome(chromeStyle, cornerRadius: LayoutConstants.CornerRadius.small)
    }

    /// Etiket sütunu her zaman yaslanan kenarda durur; değer karşı tarafa akar.
    private func splitRow(title: String, value: String, tint: Color? = nil) -> some View {
        OverlayMarkedRow(
            alignment: model.alignment,
            spacing: LayoutConstants.Spacing.medium
        ) {
            Text(title.uppercased())
                .font(.system(size: model.textSize.pointSize * 0.85, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
                .frame(width: labelWidth, alignment: model.alignment.frameAlignment)
        } content: {
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(tint ?? .white)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: valueWidth, alignment: model.alignment.frameAlignment)
        }
        .frame(width: innerWidth, alignment: model.alignment.frameAlignment)
    }
}
