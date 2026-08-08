//
//  OverlayConstants.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Fotoğraf üzerine basılan bilgi katmanının boyut sabitleri.
nonisolated enum OverlayConstants {

    /// Overlay'in tasarlandığı mantıksal genişlik (pt).
    static let referenceWidth: CGFloat = 390

    /// Fotoğraf kenarına göre yatay boşluk oranı.
    static let horizontalInsetRatio: CGFloat = 0.04

    /// Fotoğraf kenarına göre dikey boşluk oranı.
    static let verticalInsetRatio: CGFloat = 0.04

    /// Bilgi katmanı ile alt filigran arasında ek güvenlik boşluğu (genişlik oranı).
    static let watermarkGapRatio: CGFloat = 0.02

    /// Kenara yaslı katmanın dikey konumu (0 = üst, 1 = filigranın üstü).
    enum VerticalPosition {
        static let minimum: CGFloat = 0
        static let maximum: CGFloat = 1
        /// Varsayılan: alta yakın, filigranın hemen üstü.
        static let defaultValue: CGFloat = 1

        static func clamped(_ value: CGFloat) -> CGFloat {
            guard value.isFinite else { return defaultValue }

            return min(max(value, minimum), maximum)
        }
    }

    /// Alt kenar yerleşiminde filigran bandı + boşluk için ayrılan yükseklik.
    /// `AppWatermarkDrawer` iki satırlı marka yazısıyla aynı formülü kullanır.
    static func bottomContentInset(forWidth width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0 }

        let titleSize = max(Watermark.minFontSize, width * Watermark.fontSizeRatio)
        let brandFont = titleSize * Watermark.brandFontScale
        let lineHeight = brandFont * 1.2
        let lineSpacing = brandFont * Watermark.brandLineSpacingRatio
        let contentHeight = lineHeight * 2 + lineSpacing
        let shadowBlur = max(Watermark.minShadowBlur, titleSize * Watermark.shadowBlurRatio)
        let shadowYOffset = titleSize * Watermark.shadowYOffsetRatio
        let padding = shadowBlur + shadowYOffset
        let badgeHeight = contentHeight + padding * 2
        let edgeInset = width * Watermark.insetRatio
        let gap = width * watermarkGapRatio

        return badgeHeight + edgeInset + gap
    }

    /// Dikey karelerde katmanın kaplayabileceği en fazla genişlik oranı.
    static let maxWidthRatio: CGFloat = 1 - horizontalInsetRatio * 2

    /// Yatay karelerde katman genişliği (fotoğrafın kısa kenarını yutmamak için daha dar).
    static let landscapeMaxWidthRatio: CGFloat = 0.48

    /// Yatay çalışma alanında genişliğin kısa kenara göre üst sınırı.
    static let landscapeShortSideWidthCap: CGFloat = 0.92

    /// Dikey karede katman yüksekliği üst sınırı.
    static let portraitMaxHeightRatio: CGFloat = 0.55

    /// Yatay karede katman yüksekliği üst sınırı.
    static let landscapeMaxHeightRatio: CGFloat = 0.42

    /// ImageRenderer çıktısı için yarı saydam koyu arka plan.
    static let stampedBackgroundOpacity: CGFloat = 0.48

    enum MinimalShadow {
        static let opacity: CGFloat = 0.7
        static let radius: CGFloat = 2
        static let yOffset: CGFloat = 1
    }

    /// Katmanın tamamına uygulanan geometrik küçültme oranı.
    /// Yazı, iç boşluk, logo ve kart genişliği birlikte ölçeklenir.
    enum Scale {
        /// Parmakla inilebilecek en küçük oran.
        static let minimum: CGFloat = 0.45
        /// Tam boy; kart fotoğrafın kullanılabilir genişliğini kaplar.
        static let maximum: CGFloat = 1

        static func clamped(_ value: CGFloat) -> CGFloat {
            guard value.isFinite else { return maximum }

            return min(max(value, minimum), maximum)
        }
    }

    enum Text {
        static let small: CGFloat = 12
        static let medium: CGFloat = 15
        static let large: CGFloat = 19
        /// Marka adı, bilgi satırlarına göre bu oranda büyütülür.
        static let titleScale: CGFloat = 1.25
    }

    /// Fotoğraf köşelerindeki uygulama filigranları.
    /// Renkler App Icon paletinden alınır: lacivert zemin + parlak mavi vurgu.
    enum Watermark {
        static let shadowOpacity: CGFloat = 0.9
        static let shadowBlurRatio: CGFloat = 0.32
        static let minShadowBlur: CGFloat = 2
        static let shadowYOffsetRatio: CGFloat = 0.08
        static let insetRatio: CGFloat = 0.03
        static let fontSizeRatio: CGFloat = 0.026
        static let minFontSize: CGFloat = 11
        /// Doğrulama satırındaki onay ikonu.
        static let verifiedIconName = "checkmark.seal.fill"
        static let iconScale: CGFloat = 1.35
        static let iconSpacingRatio: CGFloat = 0.4
        /// Marka adı, doğrulama satırına göre küçültülür.
        static let brandFontScale: CGFloat = 0.78
        /// Kurumsal marka yazısı harf aralığı.
        static let brandKerning: CGFloat = 0.6
        /// GeoCam / audit satırları arası boşluk oranı.
        static let brandLineSpacingRatio: CGFloat = 0.05

        /// Audit yazısı mavi vurgusu (#2F85E9).
        static let brandBlueRed: CGFloat = 47 / 255
        static let brandBlueGreen: CGFloat = 133 / 255
        static let brandBlueBlue: CGFloat = 233 / 255

        /// App Icon lacivert zemini (#051C36) — gölge ve kontrast.
        static let brandNavyRed: CGFloat = 5 / 255
        static let brandNavyGreen: CGFloat = 28 / 255
        static let brandNavyBlue: CGFloat = 54 / 255
    }
}
