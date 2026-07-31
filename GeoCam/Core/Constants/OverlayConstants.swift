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

    /// Katmanın kaplayabileceği en fazla genişlik oranı (sol+sağ kenar boşluğu düşülmüş).
    static let maxWidthRatio: CGFloat = 1 - horizontalInsetRatio * 2

    /// ImageRenderer çıktısı için yarı saydam koyu arka plan.
    static let stampedBackgroundOpacity: CGFloat = 0.48

    enum Position {
        /// Katman sol kenarının varsayılan yatay konumu (0...1).
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

    enum Pinch {
        /// Bu eşiğin altında çift parmak sıkıştırma bir üst küçük boyuta geçer.
        static let shrinkThreshold: CGFloat = 0.9
        /// Bu eşiğin üstünde çift parmak açma bir üst büyük boyuta geçer.
        static let growThreshold: CGFloat = 1.12
    }

    enum Text {
        static let small: CGFloat = 12
        static let medium: CGFloat = 15
        static let large: CGFloat = 19
        /// Marka adı, bilgi satırlarına göre bu oranda büyütülür.
        static let titleScale: CGFloat = 1.25
    }
}
