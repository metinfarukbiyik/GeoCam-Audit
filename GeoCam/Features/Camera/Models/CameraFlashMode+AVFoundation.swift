//
//  CameraFlashMode+AVFoundation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation

nonisolated extension CameraFlashMode {

    var captureFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .auto: .auto
        case .on: .on
        case .off: .off
        }
    }
}
