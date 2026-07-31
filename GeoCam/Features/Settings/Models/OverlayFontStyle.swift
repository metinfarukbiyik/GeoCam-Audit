//
//  OverlayFontStyle.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Overlay metinlerinde kullanılacak yazı tipi ailesi.
nonisolated enum OverlayFontStyle: String, CaseIterable, Identifiable, Codable, Sendable {
    case standard
    case rounded
    case monospaced
    case serif

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: "Standart"
        case .rounded: "Yumuşak"
        case .monospaced: "Eşit Aralıklı"
        case .serif: "Serif"
        }
    }

    var design: Font.Design {
        switch self {
        case .standard: .default
        case .rounded: .rounded
        case .monospaced: .monospaced
        case .serif: .serif
        }
    }
}
