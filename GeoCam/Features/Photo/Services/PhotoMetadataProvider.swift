//
//  PhotoMetadataProvider.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Konum, pusula ve adres servislerinin son değerlerini tek bir metadata nesnesinde toplar.
@MainActor
final class PhotoMetadataProvider: PhotoMetadataProviding {

    private let locationService: any LocationServicing
    private let compassService: any CompassServicing
    private let addressResolver: any AddressResolving

    init(
        locationService: any LocationServicing,
        compassService: any CompassServicing,
        addressResolver: any AddressResolving
    ) {
        self.locationService = locationService
        self.compassService = compassService
        self.addressResolver = addressResolver
    }

    func currentMetadata() -> PhotoMetadata {
        PhotoMetadata(
            capturedAt: .now,
            location: locationService.currentSnapshot,
            compassReading: compassService.currentReading,
            address: addressResolver.currentAddress
        )
    }
}
