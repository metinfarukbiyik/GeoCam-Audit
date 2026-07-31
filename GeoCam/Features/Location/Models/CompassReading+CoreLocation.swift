//
//  CompassReading+CoreLocation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension CompassReading {

    /// Kalibrasyonu tamamlanmamış ölçümleri eleyerek modele dönüştürür.
    init?(_ heading: CLHeading) {
        guard heading.headingAccuracy >= 0, heading.magneticHeading >= 0 else { return nil }

        self.init(
            magneticHeading: heading.magneticHeading,
            direction: CompassDirection(degrees: heading.magneticHeading),
            timestamp: heading.timestamp
        )
    }
}
