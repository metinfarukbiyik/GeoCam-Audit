//
//  LocationSnapshot.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// Fotoğraf çekildiği ana ait konum ölçümü.
nonisolated struct LocationSnapshot: Equatable, Sendable {
    let coordinate: CLLocationCoordinate2D
    /// Deniz seviyesinden yükseklik (metre).
    let altitude: CLLocationDistance
    /// Yatay doğruluk yarıçapı (metre).
    let horizontalAccuracy: CLLocationAccuracy
    let speed: CLLocationSpeed
    let timestamp: Date

    static func == (lhs: LocationSnapshot, rhs: LocationSnapshot) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.altitude == rhs.altitude
            && lhs.horizontalAccuracy == rhs.horizontalAccuracy
            && lhs.speed == rhs.speed
            && lhs.timestamp == rhs.timestamp
    }
}
