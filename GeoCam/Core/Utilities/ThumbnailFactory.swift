//
//  ThumbnailFactory.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import ImageIO
import UIKit

/// Son çekim göstergesi için hafif küçük görseller üretir.
/// Yöntemler nonisolated async olduğundan çözümleme ana iş parçacığını meşgul etmez.
nonisolated enum ThumbnailFactory {

    static func makeThumbnail(from imageData: Data, maxPixelSize: CGFloat) async -> UIImage? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    static func makeThumbnail(fromVideoAt url: URL, maxPixelSize: CGFloat) async -> UIImage? {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: maxPixelSize, height: maxPixelSize)

        guard let cgImage = try? await generator.image(at: .zero).image else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
