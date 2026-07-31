//
//  LocationError.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Konum ve pusula akışında oluşabilecek hatalar.
nonisolated enum LocationError: UserPresentableError {
    case permissionDenied
    case servicesDisabled
    case locationUnavailable
    case geocodingFailed

    var errorDescription: String? {
        switch self {
        case .permissionDenied: "Konum erişimi reddedildi."
        case .servicesDisabled: "Konum servisleri kapalı."
        case .locationUnavailable: "Konum bilgisi alınamadı."
        case .geocodingFailed: "Adres bilgisi çözümlenemedi."
        }
    }

    var recoverySuggestionText: String? {
        switch self {
        case .permissionDenied: "Ayarlar > \(AppConstants.Info.appName) bölümünden konum erişimine izin verin."
        case .servicesDisabled: "Ayarlar > Gizlilik bölümünden konum servislerini açın."
        case .locationUnavailable: "Açık alana çıkıp tekrar deneyin."
        case .geocodingFailed: "Adres yerine koordinatlar gösterilecektir."
        }
    }
}
