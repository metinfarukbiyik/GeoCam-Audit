//
//  OverlayHorizontalAlignment.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

/// Bilgi katmanının yatay yönü; seçili köşeden türetilir.
nonisolated enum OverlayHorizontalAlignment: String, CaseIterable, Identifiable, Codable, Sendable {
    case leading
    case trailing

    var id: String { rawValue }
}
