//
//  OverlayPosition.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics

/// Bilgi katmanının sol-üst köşesinin, çerçeveye göre normalize edilmiş konumu (0...1).
/// Sol üst referans alındığı için sola yaslı tasarımlar fotoğrafta da sola hizalanır.
nonisolated struct OverlayPosition: Equatable, Codable, Sendable {
    var x: CGFloat
    var y: CGFloat

    static let `default` = OverlayPosition(
        x: OverlayConstants.Position.defaultX,
        y: OverlayConstants.Position.defaultY
    )

    /// Sürükleme mesafesini normalize ederek konuma ekler.
    func moved(by translation: CGSize, in frameSize: CGSize) -> OverlayPosition {
        guard frameSize.width > 0, frameSize.height > 0 else { return self }

        return OverlayPosition(
            x: x + translation.width / frameSize.width,
            y: y + translation.height / frameSize.height
        )
    }

    /// Katmanın çerçeve dışına ve kenar boşluklarının dışına taşmasını engeller.
    func clamped(contentSize: CGSize, in frameSize: CGSize) -> OverlayPosition {
        guard frameSize.width > 0, frameSize.height > 0 else { return self }

        let insetX = OverlayConstants.horizontalInsetRatio
        let isLandscape = frameSize.width > frameSize.height
        let maxWidthRatio = isLandscape
            ? OverlayConstants.landscapeMaxWidthRatio
            : OverlayConstants.maxWidthRatio
        let maxWidth = isLandscape
            ? min(
                frameSize.width * maxWidthRatio,
                frameSize.height * OverlayConstants.landscapeShortSideWidthCap
            )
            : frameSize.width * maxWidthRatio
        // Tam kullanılabilir genişlikte yalnızca sol kenar boşluğu geçerlidir.
        let width = min(max(contentSize.width, 0), maxWidth)
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

    /// Verilen çerçevede piksel/nokta cinsinden sol-üst köşe.
    func origin(in frameSize: CGSize) -> CGPoint {
        CGPoint(x: x * frameSize.width, y: y * frameSize.height)
    }
}
