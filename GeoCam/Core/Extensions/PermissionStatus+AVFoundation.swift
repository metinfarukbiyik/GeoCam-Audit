//
//  PermissionStatus+AVFoundation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation

nonisolated extension PermissionStatus {

    init(_ status: AVAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorized: self = .authorized
        @unknown default: self = .denied
        }
    }
}
