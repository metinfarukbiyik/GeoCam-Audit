//
//  CLLocation+Formatting.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension CLLocationCoordinate2D {

    /// Enlemin derece-dakika-saniye metni (örn. `41°00'29.7"N`).
    var latitudeSexagesimalText: String {
        Self.sexagesimalText(for: latitude, positiveSuffix: "N", negativeSuffix: "S")
    }

    /// Boylamın derece-dakika-saniye metni (örn. `28°58'42.1"E`).
    var longitudeSexagesimalText: String {
        Self.sexagesimalText(for: longitude, positiveSuffix: "E", negativeSuffix: "W")
    }

    private static func sexagesimalText(
        for value: CLLocationDegrees,
        positiveSuffix: String,
        negativeSuffix: String
    ) -> String {
        let absoluteValue = abs(value)
        var degrees = Int(absoluteValue)
        var minutes = Int((absoluteValue - Double(degrees)) * 60)
        var seconds = ((absoluteValue - Double(degrees)) * 60 - Double(minutes)) * 60

        // Tek ondalığa yuvarlama 60.0 üretirse bir üst birime taşınır; "41°00'60.0\"N" gösterilmez.
        if (seconds * 10).rounded() >= 600 {
            seconds = 0
            minutes += 1
        }

        if minutes >= 60 {
            minutes = 0
            degrees += 1
        }

        let suffix = value >= 0 ? positiveSuffix : negativeSuffix

        return String(format: "%d°%02d'%04.1f\"%@", degrees, minutes, seconds, suffix)
    }
}
