//
//  LocationSnapshot+CoreLocation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension LocationSnapshot {

    /// Geçersiz ölçümleri (negatif doğruluk) eleyerek modele dönüştürür.
    init?(_ location: CLLocation) {
        guard location.horizontalAccuracy >= 0 else { return nil }

        self.init(
            coordinate: location.coordinate,
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            speed: max(location.speed, 0),
            timestamp: location.timestamp
        )
    }

    var accuracyLevel: LocationAccuracyLevel {
        LocationAccuracyLevel(horizontalAccuracy: horizontalAccuracy)
    }
}
