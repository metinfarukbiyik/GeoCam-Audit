//
//  PermissionStatus+Photos.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Photos

nonisolated extension PermissionStatus {

    init(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined: self = .notDetermined
        case .restricted: self = .restricted
        case .denied: self = .denied
        // Sınırlı erişimde de yeni çekim eklenebilir; yalnızca albüm oluşturma devre dışı kalır.
        case .authorized, .limited: self = .authorized
        @unknown default: self = .denied
        }
    }
}
