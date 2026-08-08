//
//  InfoOverlayView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Fotoğrafın üzerine basılan bilgi katmanı.
/// Hem canlı önizlemede hem de OverlayRenderer içinde aynı görünüm kullanılır;
/// yerleşim, kullanıcının seçtiği tasarıma göre değişir.
struct InfoOverlayView: View {
    let metadata: PhotoMetadata
    let settings: OverlaySettings
    var branding: OverlayBranding?
    var chromeStyle: OverlayChromeStyle = .live
    var maxWidth: CGFloat = OverlayConstants.referenceWidth * OverlayConstants.maxWidthRatio

    var body: some View {
        let model = OverlayDisplayModel(metadata: metadata, settings: settings, branding: branding)

        Group {
            switch settings.layoutStyle {
            case .card:
                OverlayCardLayout(model: model, chromeStyle: chromeStyle, maxWidth: maxWidth)
            case .compact:
                OverlayCompactLayout(model: model, chromeStyle: chromeStyle, maxWidth: maxWidth)
            case .banner:
                OverlayBannerLayout(model: model, chromeStyle: chromeStyle, maxWidth: maxWidth)
            case .minimal:
                OverlayMinimalLayout(model: model, maxWidth: maxWidth)
            case .poster:
                OverlayPosterLayout(model: model, chromeStyle: chromeStyle, maxWidth: maxWidth)
            case .split:
                OverlaySplitLayout(model: model, chromeStyle: chromeStyle, maxWidth: maxWidth)
            case .capsule:
                OverlayCapsuleLayout(model: model, chromeStyle: chromeStyle, maxWidth: maxWidth)
            }
        }
        .font(.system(size: settings.textSize.pointSize))
        .fontDesign(settings.fontStyle.design)
        .foregroundStyle(.white)
        // Metin yönü tek yerden verilir; tasarımlar yalnızca gerektiğinde geçersiz kılar.
        .multilineTextAlignment(settings.horizontalAlignment.textAlignment)
        .frame(width: maxWidth, alignment: settings.horizontalAlignment.frameAlignment)
    }
}

private func previewSettings(for style: OverlayLayoutStyle) -> OverlaySettings {
    var settings = OverlaySettings.default
    settings.layoutStyle = style
    return settings
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()

        VStack(spacing: LayoutConstants.Spacing.medium) {
            ForEach(OverlayLayoutStyle.allCases) { style in
                InfoOverlayView(
                    metadata: PhotoMetadata(capturedAt: .now, location: nil, compassReading: nil, address: nil),
                    settings: previewSettings(for: style),
                    branding: OverlayBranding(
                        name: "GeoCam Yapı",
                        logo: nil,
                        symbolName: "building.2.fill",
                        fontStyle: .rounded,
                        accentColor: .yellow
                    ),
                    chromeStyle: .stamped,
                    maxWidth: 320
                )
            }
        }
        .padding()
    }
}
