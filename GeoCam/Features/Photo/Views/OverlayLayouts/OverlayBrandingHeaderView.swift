//
//  OverlayBrandingHeaderView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Logo / ikon ve şirket adını yan yana gösteren marka satırı.
struct OverlayBrandingHeaderView: View {
    let branding: OverlayBranding
    let textSize: OverlayTextSize
    var maxWidth: CGFloat?

    var body: some View {
        HStack(spacing: LayoutConstants.Spacing.small) {
            leadingMark
                .foregroundStyle(branding.accentColor.color)

            if let name = branding.name {
                Text(name)
                    .font(brandFont)
                    .foregroundStyle(branding.accentColor.color)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: maxWidth, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var leadingMark: some View {
        if let logo = branding.logo {
            Image(uiImage: logo)
                .resizable()
                .scaledToFit()
                .frame(height: LayoutConstants.Branding.overlayLogoHeight)
                .accessibilityHidden(true)
        } else if let symbolName = branding.symbolName {
            Image(systemName: symbolName)
                .font(.system(size: LayoutConstants.Branding.overlayIconPointSize, weight: .semibold))
                .frame(
                    width: LayoutConstants.Branding.overlayIconPointSize + 2,
                    height: LayoutConstants.Branding.overlayLogoHeight
                )
                .accessibilityHidden(true)
        }
    }

    private var brandFont: Font {
        .system(
            size: textSize.titlePointSize,
            weight: branding.fontStyle.weight,
            design: branding.fontStyle.design
        )
        .width(branding.fontStyle.width)
    }

    private var accessibilityLabel: String {
        [branding.name].compactMap { $0 }.joined(separator: " ")
    }
}

#Preview {
    ZStack {
        Color.gray
        VStack(alignment: .leading, spacing: 16) {
            OverlayBrandingHeaderView(
                branding: OverlayBranding(
                    name: "GeoCam Yapı",
                    logo: nil,
                    symbolName: "building.2.fill",
                    fontStyle: .rounded,
                    accentColor: .yellow
                )!,
                textSize: .medium,
                maxWidth: 280
            )

            OverlayBrandingHeaderView(
                branding: OverlayBranding(
                    name: "Audit Co",
                    logo: nil,
                    symbolName: "checkmark.seal.fill",
                    fontStyle: .serif,
                    accentColor: .mint
                )!,
                textSize: .medium,
                maxWidth: 280
            )
        }
        .padding()
    }
}
