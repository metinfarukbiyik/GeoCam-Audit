//
//  CameraError.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Kamera akışında oluşabilecek hatalar.
nonisolated enum CameraError: UserPresentableError {
    case permissionDenied
    case deviceUnavailable
    case configurationFailed
    case captureFailed
    case recordingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied: "Kamera erişimi reddedildi."
        case .deviceUnavailable: "Kullanılabilir bir kamera bulunamadı."
        case .configurationFailed: "Kamera yapılandırılamadı."
        case .captureFailed: "Fotoğraf çekilemedi."
        case .recordingFailed: "Video kaydedilemedi."
        }
    }

    var recoverySuggestionText: String? {
        switch self {
        case .permissionDenied: "Ayarlar > \(AppConstants.Info.appName) bölümünden kamera erişimine izin verin."
        case .deviceUnavailable, .configurationFailed, .captureFailed, .recordingFailed: "Lütfen tekrar deneyin."
        }
    }
}
