//
//  VideoOverlayRenderer.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import UIKit

/// Bilgi katmanını Core Animation katmanı olarak videoya işler.
@MainActor
final class VideoOverlayRenderer: VideoOverlayRendering {

    func render(
        videoAt sourceURL: URL,
        metadata: PhotoMetadata,
        settings: OverlaySettings,
        branding: OverlayBranding?
    ) async throws -> URL {
        let asset = AVURLAsset(url: sourceURL)
        let videoComposition = try await AVMutableVideoComposition.videoComposition(withPropertiesOf: asset)
        let renderSize = videoComposition.renderSize

        guard renderSize.width > 0, renderSize.height > 0 else { throw VideoError.unsupportedSource }

        let overlayImage = try OverlayImageFactory.makeImage(
            metadata: metadata,
            settings: settings,
            branding: branding,
            targetWidth: renderSize.width
        )

        videoComposition.animationTool = makeAnimationTool(
            overlay: overlayImage,
            position: settings.position,
            renderSize: renderSize,
            language: settings.appLanguage,
            showsAppWatermark: settings.appliesAppWatermark
        )
        applySDRColorProperties(to: videoComposition)

        return try await export(asset: asset, videoComposition: videoComposition)
    }

    // MARK: - Private

    private func makeAnimationTool(
        overlay: UIImage,
        position: OverlayPosition,
        renderSize: CGSize,
        language: AppLanguage,
        showsAppWatermark: Bool
    ) -> AVVideoCompositionCoreAnimationTool {
        let parentLayer = CALayer()
        let videoLayer = CALayer()

        parentLayer.frame = CGRect(origin: .zero, size: renderSize)
        parentLayer.isGeometryFlipped = false
        videoLayer.frame = parentLayer.frame

        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(makeOverlayLayer(overlay, position: position, renderSize: renderSize))

        if showsAppWatermark {
            parentLayer.addSublayer(
                AppWatermarkDrawer.makeLayer(renderSize: renderSize, language: language)
            )
        }

        return AVVideoCompositionCoreAnimationTool(
            postProcessingAsVideoLayer: videoLayer,
            in: parentLayer
        )
    }

    private func makeOverlayLayer(
        _ overlay: UIImage,
        position: OverlayPosition,
        renderSize: CGSize
    ) -> CALayer {
        let rect = OverlayImageFactory.rect(for: overlay, position: position, in: renderSize)
        let layer = CALayer()

        // CALayer koordinat sistemi sol alt köşeden başlar, bu yüzden dikey eksen çevrilir.
        layer.frame = CGRect(
            x: rect.minX,
            y: renderSize.height - rect.maxY,
            width: rect.width,
            height: rect.height
        )
        layer.contents = overlay.cgImage
        layer.contentsGravity = .resizeAspect

        return layer
    }

    /// Core Animation katmanı HDR kaynaklarla çalışmadığı için çıktı Rec.709'a sabitlenir.
    private func applySDRColorProperties(to videoComposition: AVMutableVideoComposition) {
        videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
    }

    private func export(
        asset: AVAsset,
        videoComposition: AVMutableVideoComposition
    ) async throws -> URL {
        guard let session = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetHighestQuality
        ) else {
            throw VideoError.exportFailed
        }

        let outputURL = Self.makeOutputURL()
        try FileManager.default.removeItemIfExists(at: outputURL)

        session.videoComposition = videoComposition
        session.outputURL = outputURL
        session.outputFileType = .mov

        await withCheckedContinuation { continuation in
            // Tamamlanma bloğu arka plan kuyruğunda çağrılır; yalnızca Sendable değer taşınır.
            session.exportAsynchronously { @Sendable in continuation.resume() }
        }

        guard session.status == .completed else {
            try? FileManager.default.removeItemIfExists(at: outputURL)
            throw VideoError.exportFailed
        }

        return outputURL
    }

    private static func makeOutputURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(CameraConstants.Video.fileExtension)
    }
}
