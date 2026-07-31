//
//  CameraFacing+AVFoundation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation

nonisolated extension CameraFacing {

    var devicePosition: AVCaptureDevice.Position {
        switch self {
        case .back: .back
        case .front: .front
        }
    }

    /// Öncelik sırasına göre denenecek kamera tipleri.
    var preferredDeviceTypes: [AVCaptureDevice.DeviceType] {
        switch self {
        case .back: [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]
        case .front: [.builtInTrueDepthCamera, .builtInWideAngleCamera]
        }
    }
}
