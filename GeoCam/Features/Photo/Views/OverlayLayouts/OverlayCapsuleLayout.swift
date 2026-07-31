//
//  OverlayCapsuleLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Her bilgiyi ayrı kapsül içinde gösteren yığılmış tasarım.
struct OverlayCapsuleLayout: View {
    let model: OverlayDisplayModel
    let chromeStyle: OverlayChromeStyle
    let maxWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.small) {
            if let branding = model.branding {
                capsule {
                    OverlayBrandingHeaderView(
                        branding: branding,
                        textSize: model.textSize,
                        maxWidth: max(maxWidth - LayoutConstants.Spacing.medium * 2, 0)
                    )
                }
            }

            if let address = model.addressText {
                capsule {
                    HStack(alignment: .top, spacing: LayoutConstants.Spacing.small) {
                        Image(systemName: "mappin.and.ellipse")
                            .accessibilityHidden(true)

                        Text(address)
                            .multilineTextAlignment(.leading)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                }
            }

            FlowDetailCapsules(rows: model.detailRows, chromeStyle: chromeStyle)
        }
        .frame(width: maxWidth, alignment: .leading)
    }

    private func capsule(@ViewBuilder content: () -> some View) -> some View {
        content()
            .padding(.horizontal, LayoutConstants.Spacing.medium)
            .padding(.vertical, LayoutConstants.Spacing.small)
            .frame(width: maxWidth, alignment: .leading)
            .overlayChrome(chromeStyle, cornerRadius: LayoutConstants.CornerRadius.large)
    }
}

/// Detay satırlarını yan yana dizip taşınca alt satıra geçen basit akış.
private struct FlowDetailCapsules: View {
    let rows: [OverlayDisplayModel.Row]
    let chromeStyle: OverlayChromeStyle

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: LayoutConstants.Spacing.small),
                GridItem(.flexible(), spacing: LayoutConstants.Spacing.small)
            ],
            alignment: .leading,
            spacing: LayoutConstants.Spacing.small
        ) {
            ForEach(rows) { row in
                HStack(spacing: LayoutConstants.Spacing.extraSmall) {
                    Image(systemName: row.systemImage)
                        .imageScale(.small)
                        .accessibilityHidden(true)

                    Text(row.displayText)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundStyle(row.tint ?? .white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, LayoutConstants.Spacing.small)
                .padding(.vertical, LayoutConstants.Spacing.small)
                .overlayChrome(chromeStyle, cornerRadius: LayoutConstants.CornerRadius.large)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(row.title) \(row.value)")
            }
        }
    }
}
