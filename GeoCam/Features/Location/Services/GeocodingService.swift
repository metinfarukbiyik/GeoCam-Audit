//
//  GeocodingService.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// CLGeocoder tabanlı reverse geocoding servisi.
@MainActor
final class GeocodingService: GeocodingServicing {

    private let geocoder = CLGeocoder()

    func address(for coordinate: CLLocationCoordinate2D) async throws -> PostalAddress {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: .current)
            guard let placemark = placemarks.first else { throw LocationError.geocodingFailed }

            return PostalAddress(placemark)
        } catch {
            throw LocationError.geocodingFailed
        }
    }
}
