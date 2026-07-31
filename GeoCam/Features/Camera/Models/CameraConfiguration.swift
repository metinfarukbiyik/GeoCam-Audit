//
//  CameraConfiguration.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Capture session'ın kullanıcı tarafından değiştirilebilen ayarları.
nonisolated struct CameraConfiguration: Equatable, Sendable {
    var facing: CameraFacing = .back
    var flashMode: CameraFlashMode = .auto
    var captureMode: CaptureMode = .photo

    static let `default` = CameraConfiguration()
}
