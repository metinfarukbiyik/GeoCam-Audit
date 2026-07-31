//
//  CapturedPhoto.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Çekilen ham fotoğraf ve ona eşlik eden bilgiler.
/// Orijinal veri hiçbir aşamada değiştirilmez; overlay ayrı bir çıktı olarak üretilir.
nonisolated struct CapturedPhoto: Identifiable, Sendable {
    let id = UUID()
    /// EXIF bilgilerini içeren orijinal fotoğraf verisi.
    let originalData: Data
    let metadata: PhotoMetadata
}
