//
//  OverlayBranding.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

/// Bilgi katmanının üstünde gösterilen şirket kimliği.
nonisolated struct OverlayBranding: Equatable, Sendable {
    let name: String?
    let logo: UIImage?
    /// Özel logo yokken marka adının önünde gösterilen SF Symbol.
    let symbolName: String?
    let fontStyle: BrandFontStyle
    let accentColor: BrandAccentColor

    /// Gösterilecek hiçbir öğe yoksa katmana marka satırı eklenmez.
    var isEmpty: Bool {
        name == nil && logo == nil
    }

    init?(
        name: String?,
        logo: UIImage?,
        symbolName: String? = nil,
        fontStyle: BrandFontStyle = .rounded,
        accentColor: BrandAccentColor = .white
    ) {
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)

        self.name = (trimmedName?.isEmpty == false) ? trimmedName : nil
        self.logo = logo
        self.symbolName = symbolName
        self.fontStyle = fontStyle
        self.accentColor = accentColor

        if isEmpty { return nil }
    }

    /// Ayarlar ve logo deposundan canlı / damgalı katman için marka üretir.
    static func make(settings: OverlaySettings, logo: UIImage?) -> OverlayBranding? {
        guard settings.showsBranding else { return nil }

        return OverlayBranding(
            name: settings.brandName,
            logo: logo,
            symbolName: settings.brandIcon.systemImageName,
            fontStyle: settings.brandFontStyle,
            accentColor: settings.brandAccentColor
        )
    }
}
