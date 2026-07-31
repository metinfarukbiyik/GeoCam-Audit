//
//  OverlayRenderer.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

/// InfoOverlayView'ı fotoğraf üzerine işler; orijinal veriyi bozmaz, EXIF'i korur.
/// Ana aktörde yalnızca küçük katman görseli üretilir; kod çözme, kırpma,
/// birleştirme ve sıkıştırma arka planda çalışır.
@MainActor
final class OverlayRenderer: OverlayRendering {

    func render(
        photo: CapturedPhoto,
        settings: OverlaySettings,
        branding: OverlayBranding?
    ) async throws -> Data {
        let baseImage = try await Self.preparedBaseImage(from: photo.originalData, settings: settings)
        let hasOverlayContent = !settings.enabledFields.isEmpty || branding != nil

        guard hasOverlayContent else {
            return try await Self.encoded(baseImage, preservingMetadataFrom: photo.originalData)
        }

        // ImageRenderer ana aktör gerektirir; yalnızca bu adım ana thread'de kalır.
        let overlayImage = try OverlayImageFactory.makeImage(
            metadata: photo.metadata,
            settings: settings,
            branding: branding,
            targetWidth: baseImage.size.width
        )

        return try await Self.composedData(
            base: baseImage,
            overlay: overlayImage,
            position: settings.position,
            originalData: photo.originalData
        )
    }

    /// Damgalı sürümle aynı orana kırpılır; bilgi katmanı eklenmez.
    func renderPlain(
        photo: CapturedPhoto,
        settings: OverlaySettings
    ) async throws -> Data {
        let baseImage = try await Self.preparedBaseImage(from: photo.originalData, settings: settings)
        return try await Self.encoded(baseImage, preservingMetadataFrom: photo.originalData)
    }

    // MARK: - Background
    // nonisolated async fonksiyonlar genel yürütücüde çalışır ve ana thread'i bloklamaz.

    private nonisolated static func preparedBaseImage(
        from data: Data,
        settings: OverlaySettings
    ) async throws -> UIImage {
        guard let decoded = UIImage(data: data)?.normalizedOrientation() else {
            throw PhotoError.renderingFailed
        }

        return decoded.cropped(toAspectRatio: targetRatio(for: decoded, settings: settings))
    }

    private nonisolated static func composedData(
        base: UIImage,
        overlay: UIImage,
        position: OverlayPosition,
        originalData: Data
    ) async throws -> Data {
        let photoSize = base.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        let overlayRect = OverlayImageFactory.rect(for: overlay, position: position, in: photoSize)

        let composed = UIGraphicsImageRenderer(size: photoSize, format: format).image { _ in
            base.draw(in: CGRect(origin: .zero, size: photoSize))
            overlay.draw(in: overlayRect)
        }

        return try await encoded(composed, preservingMetadataFrom: originalData)
    }

    /// Yatay çekimlerde kullanıcı tercihi ters çevrilerek uygulanır.
    private nonisolated static func targetRatio(for image: UIImage, settings: OverlaySettings) -> CGFloat {
        let portraitRatio = settings.aspectRatio.portraitRatio
        let isPortrait = image.size.height >= image.size.width

        return isPortrait ? portraitRatio : 1 / portraitRatio
    }

    private nonisolated static func encoded(
        _ image: UIImage,
        preservingMetadataFrom originalData: Data
    ) async throws -> Data {
        guard let cgImage = image.cgImage else { throw PhotoError.renderingFailed }

        return try PhotoMetadataWriter.jpegData(
            from: cgImage,
            preservingMetadataFrom: originalData,
            compressionQuality: CameraConstants.Output.jpegCompressionQuality
        )
    }
}
