//
//  OverlayChromeStyle.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Bilgi katmanının görsel sunum stili.
/// ImageRenderer material efektlerini güvenilir şekilde çizmediği için
/// fotoğrafa basılırken katı yarı saydam arka plan kullanılır.
nonisolated enum OverlayChromeStyle: Sendable {
    case live
    case stamped
}
