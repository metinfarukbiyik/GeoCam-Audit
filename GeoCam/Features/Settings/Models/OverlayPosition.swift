//
//  OverlayPosition.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Bilgi katmanının çerçeveye göre normalize edilmiş konumu (0...1).
/// `x`, yaslanan kenardan içeri boşluktur: sola yaslıyken soldan, sağa yaslıyken sağdan ölçülür.
/// Böylece kenar tercihi değişince katman aynı boşlukla karşı kenara taşınır.
nonisolated struct OverlayPosition: Equatable, Codable, Sendable {
    var x: CGFloat
    var y: CGFloat

    static let `default` = OverlayPosition(
        x: OverlayConstants.Position.defaultX,
        y: OverlayConstants.Position.defaultY
    )

    /// Sürükleme mesafesini normalize ederek konuma ekler.
    /// Sağa yaslıyken yatay eksen ters yönde ilerler.
    func moved(
        by translation: CGSize,
        in frameSize: CGSize,
        alignment: OverlayHorizontalAlignment
    ) -> OverlayPosition {
        guard frameSize.width > 0, frameSize.height > 0 else { return self }

        let horizontal = alignment == .leading ? translation.width : -translation.width

        return OverlayPosition(
            x: x + horizontal / frameSize.width,
            y: y + translation.height / frameSize.height
        )
    }

    /// Katmanın çerçeve dışına ve kenar boşluklarının dışına taşmasını engeller.
    func clamped(contentSize: CGSize, in frameSize: CGSize) -> OverlayPosition {
        guard frameSize.width > 0, frameSize.height > 0 else { return self }

        let insetX = OverlayConstants.horizontalInsetRatio
        let width = min(max(contentSize.width, 0), frameSize.width)
        let height = max(contentSize.height, 0)

        let measuredWidthRatio = width / frameSize.width
        let measuredHeightRatio = height / frameSize.height

        let minX = insetX
        let maxX = max(1 - insetX - measuredWidthRatio, minX)
        let minY: CGFloat = 0
        let maxY = max(1 - measuredHeightRatio, minY)

        return OverlayPosition(
            x: min(max(x, minX), maxX),
            y: min(max(y, minY), maxY)
        )
    }

    /// Verilen çerçevede nokta cinsinden sol-üst köşe.
    func origin(
        contentSize: CGSize,
        in frameSize: CGSize,
        alignment: OverlayHorizontalAlignment
    ) -> CGPoint {
        let inset = x * frameSize.width
        let originX = switch alignment {
        case .leading: inset
        case .trailing: frameSize.width - contentSize.width - inset
        }

        return CGPoint(x: originX, y: y * frameSize.height)
    }

    /// Bozuk (NaN/sonsuz) veya 0...1 dışına çıkmış kayıtlı değerleri güvenli hale getirir.
    /// Çerçeveye sığdırma işlemi burada yapılmaz; o karar görüntüleme anına aittir.
    func sanitized() -> OverlayPosition {
        OverlayPosition(
            x: Self.normalized(x, fallback: OverlayConstants.Position.defaultX),
            y: Self.normalized(y, fallback: OverlayConstants.Position.defaultY)
        )
    }

    private static func normalized(_ value: CGFloat, fallback: CGFloat) -> CGFloat {
        guard value.isFinite else { return fallback }

        return min(max(value, 0), 1)
    }
}
