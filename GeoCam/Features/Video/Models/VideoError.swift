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

    var errorDescription: String? {
        switch self {
        case .unsupportedSource: "Video okunamadı."
        case .exportFailed: "Bilgi katmanı videoya işlenemedi."
        }
    }

    var recoverySuggestionText: String? {
        "Lütfen tekrar deneyin."
    }
}
