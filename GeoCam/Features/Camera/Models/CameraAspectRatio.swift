//
//  CameraAspectRatio.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Önizlemenin ve kaydedilen fotoğrafın çerçeve oranı.
nonisolated enum CameraAspectRatio: String, CaseIterable, Identifiable, Codable, Sendable {
    /// Sensörün doğal fotoğraf oranı.
    case standard
    /// Dikey tam ekran video oranı.
    case wide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: "4:3"
        case .wide: "9:16"
        }
    }

    /// Dikey yerleşimde genişlik / yükseklik oranı.
    var portraitRatio: CGFloat {
        switch self {
        case .standard: 3.0 / 4.0
        case .wide: 9.0 / 16.0
        }
    }
}
