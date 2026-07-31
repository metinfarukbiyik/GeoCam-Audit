//
//  OverlayTextSize.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Bilgi katmanındaki metinlerin boyutu.
/// Fotoğrafa basılan çıktı deterministik olmalıdır, bu yüzden sabit punto kullanılır.
nonisolated enum OverlayTextSize: String, CaseIterable, Identifiable, Codable, Sendable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .small: "Küçük"
        case .medium: "Orta"
        case .large: "Büyük"
        }
    }

    /// Bilgi satırlarının punto değeri.
    var pointSize: CGFloat {
        switch self {
        case .small: OverlayConstants.Text.small
        case .medium: OverlayConstants.Text.medium
        case .large: OverlayConstants.Text.large
        }
    }

    /// Marka adının punto değeri.
    var titlePointSize: CGFloat {
        pointSize * OverlayConstants.Text.titleScale
    }

    var smaller: OverlayTextSize? {
        switch self {
        case .small: nil
        case .medium: .small
        case .large: .medium
        }
    }

    var larger: OverlayTextSize? {
        switch self {
        case .small: .medium
        case .medium: .large
        case .large: nil
        }
    }
}
