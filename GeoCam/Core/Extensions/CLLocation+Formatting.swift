//
//  CLLocation+Formatting.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension CLLocationCoordinate2D {

    /// Ondalık koordinat metni (örn. "41.00824, 28.97836").
    /// Beş ondalık taşmayı azaltır; yaklaşık 1 m hassasiyet yeterlidir.
    var decimalText: String {
        let latitudeText = latitude.formatted(.number.precision(.fractionLength(5)).grouping(.never))
        let longitudeText = longitude.formatted(.number.precision(.fractionLength(5)).grouping(.never))
        return "\(latitudeText), \(longitudeText)"
    }

    /// Derece-dakika-saniye koordinat metni (örn. "41°00'29.7\"N 28°58'42.1\"E").
    var sexagesimalText: String {
        let latitudeText = Self.sexagesimalText(for: latitude, positiveSuffix: "N", negativeSuffix: "S")
        let longitudeText = Self.sexagesimalText(for: longitude, positiveSuffix: "E", negativeSuffix: "W")
        return "\(latitudeText) \(longitudeText)"
    }

    private static func sexagesimalText(
        for value: CLLocationDegrees,
        positiveSuffix: String,
        negativeSuffix: String
    ) -> String {
        let absoluteValue = abs(value)
        let degrees = Int(absoluteValue)
        let minutesValue = (absoluteValue - Double(degrees)) * 60
        let minutes = Int(minutesValue)
        let seconds = (minutesValue - Double(minutes)) * 60
        let suffix = value >= 0 ? positiveSuffix : negativeSuffix

        return String(format: "%d°%02d'%04.1f\"%@", degrees, minutes, seconds, suffix)
    }
}
