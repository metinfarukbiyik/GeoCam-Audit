//
//  PostalAddress+CoreLocation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

nonisolated extension PostalAddress {

    init(_ placemark: CLPlacemark) {
        self.init(
            neighborhood: placemark.subLocality,
            district: placemark.subAdministrativeArea ?? placemark.locality,
            city: placemark.administrativeArea ?? placemark.locality,
            country: placemark.country
        )
    }
}
