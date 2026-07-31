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

    func presentableTitle(language: AppLanguage) -> String {
        switch self {
        case .permissionDenied: language.t(.errorLocationPermission)
        case .servicesDisabled: language.t(.errorLocationDisabled)
        case .locationUnavailable: language.t(.errorLocationUnavailable)
        case .geocodingFailed: language.t(.errorGeocoding)
        }
    }

    func presentableRecovery(language: AppLanguage) -> String? {
        switch self {
        case .permissionDenied:
            language.t(.errorLocationPermissionHint, AppConstants.Info.appName)
        case .servicesDisabled:
            language.t(.errorLocationDisabledHint)
        case .locationUnavailable:
            language.t(.errorTryAgain)
        case .geocodingFailed:
            language.t(.errorGeocodingHint)
        }
    }
}
