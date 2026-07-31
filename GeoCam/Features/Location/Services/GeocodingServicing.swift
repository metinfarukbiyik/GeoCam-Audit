//
//  GeocodingServicing.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// Koordinattan açık adres çözümlemeyi soyutlar.
@MainActor
protocol GeocodingServicing: AnyObject {
    func address(for coordinate: CLLocationCoordinate2D) async throws -> PostalAddress
}
