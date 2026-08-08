//
//  OverlayImageFactory.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI
import UIKit

/// Bilgi katmanını görüntüye dönüştürür ve hedef çerçevedeki yerini hesaplar.
/// Fotoğraf ve video işleyicileri aynı sonucu üretmek için buradan geçer.
@MainActor
enum OverlayImageFactory {

    /// Katmanı hedef kare boyutuna göre ölçekleyerek üretir.
    /// Kullanıcının seçtiği layout korunur; yatay karelerde yalnızca ölçek daraltılır.
    static func makeImage(
        metadata: PhotoMetadata,
        settings: OverlaySettings,
        branding: OverlayBranding?,
        targetSize: CGSize
    ) throws -> UIImage {
        let placement = Placement.make(for: targetSize, scale: settings.resolvedScale)

        let content = InfoOverlayView(
            metadata: metadata,
            settings: settings,
            branding: branding,
            chromeStyle: .stamped,
            maxWidth: placement.layoutWidth
        )
        .frame(width: placement.layoutWidth, alignment: .leading)

        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(width: placement.layoutWidth, height: nil)
        renderer.scale = max(placement.scale, 1)

        guard let image = renderer.uiImage else { throw PhotoError.renderingFailed }

        return image
    }

    /// Katmanın hedef çerçevedeki dikdörtgeni. Sol üst köşe başlangıçlı koordinat sistemine göredir.
    /// Saf geometri hesabı olduğu için herhangi bir thread'den çağrılabilir.
    nonisolated static func rect(
        for image: UIImage,
        settings: OverlaySettings,
        in frameSize: CGSize
    ) -> CGRect {
        let placement = Placement.make(for: frameSize, scale: settings.resolvedScale)
        let size = placement.fittedSize(for: image.size, in: frameSize)
        let origin = settings.corner.origin(
            contentSize: size,
            in: frameSize,
            verticalPosition: settings.resolvedVerticalPosition
        )

        return CGRect(origin: origin, size: size)
    }

    // MARK: - Placement

    /// Hedef kareye göre mantıksal genişlik, ölçek ve yükseklik tavanı.
    nonisolated struct Placement: Sendable {
        let isLandscape: Bool
        let layoutWidth: CGFloat
        /// Layout noktasından fotoğraf noktasına ölçek.
        let scale: CGFloat
        let maxHeightRatio: CGFloat
        let maxWidthRatio: CGFloat

        static func make(for frameSize: CGSize, scale overlayScale: CGFloat) -> Placement {
            let isLandscape = frameSize.width > frameSize.height
            let userScale = OverlayConstants.Scale.clamped(overlayScale)

            // Aynı seçili tasarım çizilir; yatayda ve küçültmede yalnızca ölçek değişir.
            let layoutWidth = OverlayConstants.referenceWidth * OverlayConstants.maxWidthRatio
            let widthRatio = isLandscape
                ? OverlayConstants.landscapeMaxWidthRatio
                : OverlayConstants.maxWidthRatio
            let heightRatio = isLandscape
                ? OverlayConstants.landscapeMaxHeightRatio
                : OverlayConstants.portraitMaxHeightRatio

            let uncappedWidth = max(frameSize.width * widthRatio, 1)
            let fittedWidth = isLandscape
                ? min(
                    uncappedWidth,
                    frameSize.height * OverlayConstants.landscapeShortSideWidthCap
                )
                : uncappedWidth
            let desiredWidth = fittedWidth * userScale
            let scale = desiredWidth / max(layoutWidth, 1)

            return Placement(
                isLandscape: isLandscape,
                layoutWidth: layoutWidth,
                scale: scale,
                maxHeightRatio: heightRatio * userScale,
                maxWidthRatio: desiredWidth / max(frameSize.width, 1)
            )
        }

        func fittedSize(for imageSize: CGSize, in frameSize: CGSize) -> CGSize {
            var size = CGSize(
                width: imageSize.width * scale,
                height: imageSize.height * scale
            )

            let maxHeight = frameSize.height * maxHeightRatio
            if size.height > maxHeight, size.height > 0 {
                let shrink = maxHeight / size.height
                size.width *= shrink
                size.height = maxHeight
            }

            let maxWidth = frameSize.width * maxWidthRatio
            if size.width > maxWidth, size.width > 0 {
                let shrink = maxWidth / size.width
                size.width = maxWidth
                size.height *= shrink
            }

            return size
        }
    }
}
