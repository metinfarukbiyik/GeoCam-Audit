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
        VStack(alignment: model.alignment.stackAlignment, spacing: LayoutConstants.Spacing.small) {
            if let branding = model.branding {
                capsule {
                    OverlayBrandingHeaderView(
                        branding: branding,
                        textSize: model.textSize,
                        alignment: model.alignment,
                        maxWidth: max(maxWidth - LayoutConstants.Spacing.medium * 2, 0)
                    )
                }
            }

            if let address = model.addressText {
                capsule {
                    OverlayMarkedRow(alignment: model.alignment) {
                        Image(systemName: "mappin.and.ellipse")
                            .accessibilityHidden(true)
                    } content: {
                        Text(address)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: model.alignment.frameAlignment)
                    }
                }
            }

            FlowDetailCapsules(
                rows: model.detailRows,
                chromeStyle: chromeStyle,
                alignment: model.alignment
            )
        }
        .frame(width: maxWidth, alignment: model.alignment.frameAlignment)
    }

    private func capsule(@ViewBuilder content: () -> some View) -> some View {
        content()
            .padding(.horizontal, LayoutConstants.Spacing.medium)
            .padding(.vertical, LayoutConstants.Spacing.small)
            .frame(width: maxWidth, alignment: model.alignment.frameAlignment)
            .overlayChrome(chromeStyle, cornerRadius: LayoutConstants.CornerRadius.large)
    }
}

/// Detay satırlarını yan yana dizip taşınca alt satıra geçen basit akış.
private struct FlowDetailCapsules: View {
    let rows: [OverlayDisplayModel.Row]
    let chromeStyle: OverlayChromeStyle
    let alignment: OverlayHorizontalAlignment

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: LayoutConstants.Spacing.small),
                GridItem(.flexible(), spacing: LayoutConstants.Spacing.small)
            ],
            alignment: alignment.stackAlignment,
            spacing: LayoutConstants.Spacing.small
        ) {
            ForEach(rows) { row in
                OverlayMarkedRow(
                    alignment: alignment,
                    verticalAlignment: .center,
                    spacing: LayoutConstants.Spacing.extraSmall
                ) {
                    Image(systemName: row.systemImage)
                        .imageScale(.small)
                        .accessibilityHidden(true)
                } content: {
                    Text(row.displayText)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundStyle(row.tint ?? .white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: alignment.frameAlignment)
                }
                .frame(maxWidth: .infinity, alignment: alignment.frameAlignment)
                .padding(.horizontal, LayoutConstants.Spacing.small)
                .padding(.vertical, LayoutConstants.Spacing.small)
                .overlayChrome(chromeStyle, cornerRadius: LayoutConstants.CornerRadius.large)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(row.title) \(row.value)")
            }
        }
    }
}
