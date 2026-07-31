//
//  PhotoMetadataWriter.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import ImageIO
import UniformTypeIdentifiers

/// Orijinal fotoğrafın EXIF/GPS metadata'sını yeni görüntüye aktarır.
nonisolated enum PhotoMetadataWriter {

    /// Yönü piksele işlenmiş görüntü için orientation=1 ile JPEG üretir.
    static func jpegData(
        from cgImage: CGImage,
        preservingMetadataFrom originalData: Data,
        compressionQuality: Double
    ) throws -> Data {
        guard let source = CGImageSourceCreateWithData(originalData as CFData, nil) else {
            throw PhotoError.renderingFailed
        }

        let mutableData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            mutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw PhotoError.renderingFailed
        }

        var properties = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]) ?? [:]
        normalizeOrientation(in: &properties)
        properties[kCGImageDestinationLossyCompressionQuality as String] = compressionQuality

        CGImageDestinationAddImage(destination, cgImage, properties as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw PhotoError.renderingFailed
        }

        return mutableData as Data
    }

    /// Piksel verisi dikleştirildiği için tüm orientation alanları "1 / Up" yapılır.
    private static func normalizeOrientation(in properties: inout [String: Any]) {
        properties[kCGImagePropertyOrientation as String] = 1

        if var tiff = properties[kCGImagePropertyTIFFDictionary as String] as? [String: Any] {
            tiff[kCGImagePropertyTIFFOrientation as String] = 1
            properties[kCGImagePropertyTIFFDictionary as String] = tiff
        }

        if var exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
            exif.removeValue(forKey: kCGImagePropertyOrientation as String)
            properties[kCGImagePropertyExifDictionary as String] = exif
        }
    }
}
