//
//  OverlayRendering.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Bilgi katmanının fotoğrafa işlenmesini soyutlar.
@MainActor
protocol OverlayRendering: AnyObject {
    /// Orijinal veriyi bozmadan, overlay basılmış yeni bir fotoğraf verisi üretir.
    func render(
        photo: CapturedPhoto,
        settings: OverlaySettings,
        branding: OverlayBranding?
    ) async throws -> Data

    /// Seçili çerçeve oranına kırpılmış, katmansız kopya üretir.
    func renderPlain(
        photo: CapturedPhoto,
        settings: OverlaySettings
    ) async throws -> Data
}
