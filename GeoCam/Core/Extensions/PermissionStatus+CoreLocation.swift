//
//  PermissionStatus+CoreLocation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension PermissionStatus {

    init(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        case .authorizedWhenInUse, .authorizedAlways: self = .authorized
        @unknown default: self = .denied
        }
    }
}
