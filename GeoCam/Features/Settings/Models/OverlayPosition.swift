//
//  OverlayPosition.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Eski serbest konum modeli; yalnızca kayıt göçü için çözülür.
/// Yerleşim artık `OverlayCorner` ile yapılır.
nonisolated struct OverlayPosition: Equatable, Codable, Sendable {
    var x: CGFloat
    var y: CGFloat

    func sanitized() -> OverlayPosition {
        OverlayPosition(
            x: Self.normalized(x),
            y: Self.normalized(y)
        )
    }

    private static func normalized(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0 }

        return min(max(value, 0), 1)
    }
}
