//
//  OverlayBannerLayout.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Tam genişlik şerit tasarımı: adres başlık, detaylar iki sütun.
struct OverlayBannerLayout: View {
    let model: OverlayDisplayModel
    let chromeStyle: OverlayChromeStyle
    let maxWidth: CGFloat

    private static let columnCount = 2

    private var innerWidth: CGFloat {
        max(maxWidth - LayoutConstants.Spacing.medium * 2, 0)
    }

    var body: some View {
        VStack(alignment: model.alignment.stackAlignment, spacing: LayoutConstants.Spacing.small) {
            if let branding = model.branding {
                OverlayBrandingHeaderView(
                    branding: branding,
                    textSize: model.textSize,
                    alignment: model.alignment,
                    maxWidth: innerWidth
                )
            }

            if let address = model.addressText {
                Text(address)
                    .font(.system(size: model.textSize.titlePointSize, weight: .semibold))
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: model.alignment.frameAlignment)
            }

            if !model.detailRows.isEmpty {
                detailGrid
            }
        }
        .padding(LayoutConstants.Spacing.medium)
        .frame(width: maxWidth, alignment: model.alignment.frameAlignment)
        .overlayChrome(chromeStyle, cornerRadius: LayoutConstants.CornerRadius.small)
    }

    private var detailGrid: some View {
        Grid(
            alignment: model.alignment.frameAlignment,
            horizontalSpacing: LayoutConstants.Spacing.large,
            verticalSpacing: LayoutConstants.Spacing.extraSmall
        ) {
            ForEach(rowPairs, id: \.self) { pairIndex in
                GridRow {
                    ForEach(pair(at: pairIndex)) { row in
                        cell(for: row)
                    }
                }
            }
        }
        .frame(width: innerWidth, alignment: model.alignment.frameAlignment)
    }

    private var rowPairs: [Int] {
        Array(stride(from: 0, to: model.detailRows.count, by: Self.columnCount))
    }

    private func pair(at startIndex: Int) -> [OverlayDisplayModel.Row] {
        let endIndex = min(startIndex + Self.columnCount, model.detailRows.count)
        return Array(model.detailRows[startIndex..<endIndex])
    }

    private func cell(for row: OverlayDisplayModel.Row) -> some View {
        OverlayMarkedRow(
            alignment: model.alignment,
            verticalAlignment: .center,
            spacing: LayoutConstants.Spacing.extraSmall
        ) {
            Image(systemName: row.systemImage)
                .imageScale(.small)
                .foregroundStyle(.white.opacity(0.75))
                .accessibilityHidden(true)
        } content: {
            Text(row.displayText)
                .fontWeight(.medium)
                .foregroundStyle(row.tint ?? .white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: model.alignment.frameAlignment)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.title) \(row.value)")
    }
}
