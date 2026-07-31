//
//  CameraZoomFactor.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics
import Foundation

/// Kullanıcıya sunulan optik/dijital yakınlaştırma basamakları.
nonisolated enum CameraZoomFactor: CGFloat, CaseIterable, Identifiable, Sendable {
    case ultraWide = 0.5
    case wide = 1.0
    case telephoto = 2.0

    var id: CGFloat { rawValue }

    var title: String {
        switch self {
        case .ultraWide: "0.5"
        case .wide: "1×"
        case .telephoto: "2"
        }
    }

    /// Seçili basamağın vurgulu metin gösterimi.
    var selectedTitle: String {
        switch self {
        case .ultraWide: "0.5×"
        case .wide: "1×"
        case .telephoto: "2×"
        }
    }
}
