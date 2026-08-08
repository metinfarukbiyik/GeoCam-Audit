//
//  PhotoMetadata+Display.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

nonisolated extension PhotoMetadata {

    var dateText: String { capturedAt.overlayDateText }
    var timeText: String { capturedAt.overlayTimeText }

    var addressText: String? {
        address?.formatted
    }

    /// Derece-dakika-saniye metni (örn. `41°00'29.7"N 28°58'42.1"E`).
    var coordinateText: String? {
        guard let coordinate = location?.coordinate else { return nil }

        return "\(coordinate.latitudeSexagesimalText) \(coordinate.longitudeSexagesimalText)"
    }

    /// Adres yoksa koordinat; konum satırı için yedek metin.
    var placeText: String? {
        addressText ?? coordinateText
    }

    var altitudeText: String? {
        location?.altitude.metersText
    }

    var accuracyText: String? {
        location?.horizontalAccuracy.metersText
    }

    var headingText: String? {
        guard let reading = compassReading else { return nil }
        return "\(Int(reading.magneticHeading.rounded()))° \(reading.direction.abbreviation)"
    }
}
