//
//  PhotoError.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Fotoğraf işleme ve kaydetme akışındaki hatalar.
nonisolated enum PhotoError: UserPresentableError {
    case libraryPermissionDenied
    case renderingFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .libraryPermissionDenied: "Fotoğraflar erişimi reddedildi."
        case .renderingFailed: "Bilgi katmanı fotoğrafa işlenemedi."
        case .saveFailed: "Fotoğraf kaydedilemedi."
        }
    }

    var recoverySuggestionText: String? {
        switch self {
        case .libraryPermissionDenied: "Ayarlar > \(AppConstants.Info.appName) bölümünden Fotoğraflar erişimine izin verin."
        case .renderingFailed, .saveFailed: "Lütfen tekrar deneyin."
        }
    }
}
