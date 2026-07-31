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

    var coordinateText: String? {
        location?.coordinate.decimalText
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
