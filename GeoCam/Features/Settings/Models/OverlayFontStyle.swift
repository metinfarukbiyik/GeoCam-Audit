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

    func title(language: AppLanguage) -> String {
        switch self {
        case .standard: language.t(.fontStandard)
        case .rounded: language.t(.fontRounded)
        case .monospaced: language.t(.fontMonospaced)
        case .serif: language.t(.fontSerif)
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
