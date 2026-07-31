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

    /// Katmanı hedef genişliğe göre ölçekleyerek üretir.
    static func makeImage(
        metadata: PhotoMetadata,
        settings: OverlaySettings,
        branding: OverlayBranding?,
        targetWidth: CGFloat
    ) throws -> UIImage {
        let referenceWidth = OverlayConstants.referenceWidth
        let maxWidth = referenceWidth * OverlayConstants.maxWidthRatio

        // Sabit genişlik önerisi; ImageRenderer çıktısı fotoğraf kenarından taşmaz.
        let content = InfoOverlayView(
            metadata: metadata,
            settings: settings,
            branding: branding,
            chromeStyle: .stamped,
            maxWidth: maxWidth
        )
        .frame(width: maxWidth, alignment: .leading)

        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = ProposedViewSize(width: maxWidth, height: nil)
        renderer.scale = max(targetWidth / referenceWidth, 1)

        guard let image = renderer.uiImage else { throw PhotoError.renderingFailed }

        return image
    }

    /// Katmanın hedef çerçevedeki dikdörtgeni. Sol üst köşe başlangıçlı koordinat sistemine göredir.
    /// Saf geometri hesabı olduğu için herhangi bir thread'den çağrılabilir.
    nonisolated static func rect(for image: UIImage, position: OverlayPosition, in frameSize: CGSize) -> CGRect {
        let ratio = frameSize.width / OverlayConstants.referenceWidth
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let origin = position.clamped(contentSize: size, in: frameSize).origin(in: frameSize)

        return CGRect(origin: origin, size: size)
    }
}
