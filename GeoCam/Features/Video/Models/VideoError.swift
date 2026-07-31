//
//  VideoError.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Video işleme akışındaki hatalar.
nonisolated enum VideoError: UserPresentableError {
    case unsupportedSource
    case exportFailed

    func presentableTitle(language: AppLanguage) -> String {
        switch self {
        case .unsupportedSource: language.t(.errorVideoUnsupported)
        case .exportFailed: language.t(.errorVideoExport)
        }
    }

    func presentableRecovery(language: AppLanguage) -> String? {
        language.t(.errorTryAgain)
    }
}
