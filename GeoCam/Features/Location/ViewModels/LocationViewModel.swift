//
//  LocationViewModel.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation
import Observation

/// Konum, pusula ve adres bilgisini tek bir sunum durumunda birleştirir.
@MainActor
@Observable
final class LocationViewModel {

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

    // MARK: - State

    var permissionStatus: PermissionStatus { locationService.permissionStatus }

    private var snapshot: LocationSnapshot? { locationService.currentSnapshot }

    /// Konum ölçümü ya da pusula verisi gelene kadar arama durumu gösterilir.
    var isSearching: Bool { snapshot == nil && compassService.currentReading == nil }

    /// Canlı önizlemenin fotoğrafa basılacak katmanla birebir aynı görünmesi için
    /// anlık değerler PhotoMetadata olarak sunulur.
    var currentMetadata: PhotoMetadata {
        PhotoMetadata(
            capturedAt: .now,
            location: snapshot,
            compassReading: compassService.currentReading,
            address: addressResolver.currentAddress
        )
    }

    // MARK: - Lifecycle

    func start() async {
        let status = await locationService.requestPermission()
        guard status.isAuthorized else { return }

        locationService.startUpdates()
        compassService.startUpdates()
        addressResolver.start()
    }

    func stop() {
        locationService.stopUpdates()
        compassService.stopUpdates()
        addressResolver.stop()
    }
}
