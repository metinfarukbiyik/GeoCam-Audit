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

    var title: String {
        switch self {
        case .white: "Beyaz"
        case .yellow: "Sarı"
        case .orange: "Turuncu"
        case .green: "Yeşil"
        case .mint: "Nane"
        case .cyan: "Camgöbeği"
        case .blue: "Mavi"
        case .pink: "Pembe"
        case .red: "Kırmızı"
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
