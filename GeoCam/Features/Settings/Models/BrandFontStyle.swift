//
//  BrandFontStyle.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Marka adı için yazı tipi seçenekleri.
nonisolated enum BrandFontStyle: String, CaseIterable, Identifiable, Codable, Sendable {
    case rounded
    case serif
    case monospaced
    case standard
    case condensed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rounded: "Yuvarlak"
        case .serif: "Serif"
        case .monospaced: "Eşit Aralıklı"
        case .standard: "Standart"
        case .condensed: "Sıkışık"
        }
    }

    var design: Font.Design {
        switch self {
        case .rounded: .rounded
        case .serif: .serif
        case .monospaced: .monospaced
        case .standard, .condensed: .default
        }
    }

    var weight: Font.Weight {
        switch self {
        case .rounded, .condensed: .bold
        case .serif, .standard, .monospaced: .semibold
        }
    }

    var width: Font.Width {
        switch self {
        case .condensed: .condensed
        default: .standard
        }
    }
}
