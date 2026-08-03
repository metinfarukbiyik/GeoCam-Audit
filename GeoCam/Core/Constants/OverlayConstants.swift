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

    enum Position {
        /// Katmanın yaslandığı kenardan varsayılan yatay boşluğu (0...1).
        static let defaultX: CGFloat = OverlayConstants.horizontalInsetRatio
        /// Katman üst kenarının varsayılan dikey konumu (0...1).
        /// Kontrollerin üstünde kalacak şekilde yerleştirilir.
        static let defaultY: CGFloat = 0.62
    }

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

    /// Sağ alt köşe uygulama filigranı.
    enum Watermark {
        static let opacity: CGFloat = 0.55
        static let secondaryOpacity: CGFloat = 0.48
        static let shadowOpacity: CGFloat = 0.45
        static let shadowRadius: CGFloat = 1.5
        static let insetRatio: CGFloat = 0.03
        static let fontSizeRatio: CGFloat = 0.028
        static let secondaryFontScale: CGFloat = 0.78
        static let minFontSize: CGFloat = 11
        static let minSecondaryFontSize: CGFloat = 9
        static let lineSpacingRatio: CGFloat = 0.18
        /// Video `CATextLayer` için ekrandan bağımsız içerik ölçeği.
        static let contentsScale: CGFloat = 3
    }
}
