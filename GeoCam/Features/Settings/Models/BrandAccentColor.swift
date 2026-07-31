//
//  BrandAccentColor.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Marka adı ve ikonu için vurgu rengi.
nonisolated enum BrandAccentColor: String, CaseIterable, Identifiable, Codable, Sendable {
    case white
    case yellow
    case orange
    case green
    case mint
    case cyan
    case blue
    case pink
    case red

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .white: language.t(.brandColorWhite)
        case .yellow: language.t(.brandColorYellow)
        case .orange: language.t(.brandColorOrange)
        case .green: language.t(.brandColorGreen)
        case .mint: language.t(.brandColorMint)
        case .cyan: language.t(.brandColorCyan)
        case .blue: language.t(.brandColorBlue)
        case .pink: language.t(.brandColorPink)
        case .red: language.t(.brandColorRed)
        }
    }

    var color: Color {
        switch self {
        case .white: .white
        case .yellow: .yellow
        case .orange: .orange
        case .green: .green
        case .mint: .mint
        case .cyan: .cyan
        case .blue: .blue
        case .pink: .pink
        case .red: .red
        }
    }
}
