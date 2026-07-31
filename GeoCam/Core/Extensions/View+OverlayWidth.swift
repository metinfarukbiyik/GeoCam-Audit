//
//  View+OverlayWidth.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Bilgi katmanı düzenlerine üstten inen maksimum genişlik.
private struct OverlayMaxWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 320
}

extension EnvironmentValues {
    var overlayMaxWidth: CGFloat {
        get { self[OverlayMaxWidthKey.self] }
        set { self[OverlayMaxWidthKey.self] = newValue }
    }
}

extension View {
    /// Uzun metinlerin HStack içinde kutuyu genişletmesini engeller.
    /// `minWidth: 0` olmadan Text ideal genişliğini korur ve taşıma oluşur.
    func overlayBoundedText() -> some View {
        multilineTextAlignment(.leading)
            .lineLimit(4)
            .minimumScaleFactor(0.75)
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .layoutPriority(-1)
    }
}
