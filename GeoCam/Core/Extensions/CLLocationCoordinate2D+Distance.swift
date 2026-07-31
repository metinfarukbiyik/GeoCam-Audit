//
//  CLLocationCoordinate2D+Distance.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension CLLocationCoordinate2D {

    /// İki koordinat arasındaki mesafeyi metre cinsinden verir.
    func distance(to other: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
}
