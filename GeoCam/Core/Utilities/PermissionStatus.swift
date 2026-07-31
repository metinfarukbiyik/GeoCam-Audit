//
//  PermissionStatus.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Kamera, konum ve fotoğraf kitaplığı izinleri için ortak durum modeli.
nonisolated enum PermissionStatus: Equatable, Sendable {
    case notDetermined
    case denied
    case restricted
    case authorized

    var isAuthorized: Bool { self == .authorized }

    /// Kullanıcının Ayarlar uygulamasına yönlendirilmesi gerekiyor mu?
    var requiresSettingsRedirect: Bool {
        self == .denied || self == .restricted
    }
}
