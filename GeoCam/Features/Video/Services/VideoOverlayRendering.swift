//
//  VideoOverlayRendering.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Bilgi katmanının videoya işlenmesini soyutlar.
@MainActor
protocol VideoOverlayRendering: AnyObject {
    /// Kaynağı bozmadan, katman basılmış yeni bir video dosyası üretir ve konumunu döndürür.
    func render(
        videoAt sourceURL: URL,
        metadata: PhotoMetadata,
        settings: OverlaySettings,
        branding: OverlayBranding?
    ) async throws -> URL
}
