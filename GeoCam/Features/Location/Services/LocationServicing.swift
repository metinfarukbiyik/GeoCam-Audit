//
//  LocationServicing.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Konum güncellemelerini soyutlar.
@MainActor
protocol LocationServicing: AnyObject {
    var permissionStatus: PermissionStatus { get }
    var currentSnapshot: LocationSnapshot? { get }
    var lastError: LocationError? { get }

    func requestPermission() async -> PermissionStatus
    func startUpdates()
    func stopUpdates()
}
