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

    func presentableTitle(language: AppLanguage) -> String {
        switch self {
        case .libraryPermissionDenied: language.t(.errorPhotosPermission)
        case .renderingFailed: language.t(.errorPhotosRender)
        case .saveFailed: language.t(.errorPhotosSave)
        }
    }

    func presentableRecovery(language: AppLanguage) -> String? {
        switch self {
        case .libraryPermissionDenied:
            language.t(.errorPhotosPermissionHint, AppConstants.Info.appName)
        case .renderingFailed, .saveFailed:
            language.t(.errorTryAgain)
        }
    }
}
