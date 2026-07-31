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

    func presentableTitle(language: AppLanguage) -> String {
        switch self {
        case .permissionDenied: language.t(.errorCameraPermission)
        case .deviceUnavailable: language.t(.errorCameraUnavailable)
        case .configurationFailed: language.t(.errorCameraConfig)
        case .captureFailed: language.t(.errorCameraCapture)
        case .recordingFailed: language.t(.errorCameraRecording)
        }
    }

    func presentableRecovery(language: AppLanguage) -> String? {
        switch self {
        case .permissionDenied:
            language.t(.errorCameraPermissionHint, AppConstants.Info.appName)
        case .deviceUnavailable, .configurationFailed, .captureFailed, .recordingFailed:
            language.t(.errorTryAgain)
        }
    }
}
