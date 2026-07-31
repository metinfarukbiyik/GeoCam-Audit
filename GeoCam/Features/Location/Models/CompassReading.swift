//
//  CompassReading.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// Pusuladan alınan tek bir ölçüm.
nonisolated struct CompassReading: Equatable, Sendable {
    /// Manyetik kuzeye göre yön (0-360°).
    let magneticHeading: CLLocationDirection
    let direction: CompassDirection
    let timestamp: Date
}
