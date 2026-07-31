//
//  LayoutConstants.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Arayüz boyut ve boşluk sabitleri.
nonisolated enum LayoutConstants {

    enum Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum SideMenu {
        /// Çekmecenin ekran genişliğine oranı.
        static let widthRatio: CGFloat = 0.84
        static let maxWidth: CGFloat = 360
        /// Çekmeceyi kapatmak için gereken minimum sürükleme mesafesi.
        static let dismissDragThreshold: CGFloat = 60
        static let backdropOpacity: CGFloat = 0.4
    }

    enum Branding {
        /// Ayarlar ekranındaki logo önizlemesinin kenar uzunluğu.
        static let logoPreviewSize: CGFloat = 56
        /// Bilgi katmanındaki logonun yüksekliği.
        static let overlayLogoHeight: CGFloat = 28
        /// Özel logo yokken kullanılan SF Symbol punto boyutu.
        static let overlayIconPointSize: CGFloat = 18
        /// Saklanan logonun uzun kenar sınırı.
        static let maxLogoDimension: CGFloat = 512
    }

    enum Splash {
        /// Ekran genişliğine göre logo oranı; taşmayı önler.
        static let logoWidthRatio: CGFloat = 0.42
        static let maxLogoSize: CGFloat = 180
        /// Logo köşe yuvarlaklığı (kenar uzunluğuna oran).
        static let logoCornerRatio: CGFloat = 0.22
        static let titleSize: CGFloat = 34
    }

    enum ZoomControl {
        static let buttonDiameter: CGFloat = 36
        static let spacing: CGFloat = 10
    }

    enum Thumbnail {
        /// Deklanşörün solundaki son çekim göstergesinin kenar uzunluğu.
        static let size: CGFloat = 52
        static let borderWidth: CGFloat = 1.5
        /// Bellekte tutulan küçük görselin uzun kenar sınırı.
        static let maxPixelDimension: CGFloat = 240
    }

    enum CaptureButton {
        static let outerDiameter: CGFloat = 76
        static let innerDiameter: CGFloat = 62
        static let borderWidth: CGFloat = 4
    }
}
