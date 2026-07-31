//
//  AppDependencies.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation
import Observation

/// Uygulamanın kompozisyon kökü.
/// Servisler burada bir kez üretilir, görünüm modelleri buradan türetilir.
@MainActor
@Observable
final class AppDependencies {

    let cameraManager: any CameraManaging
    let locationService: any LocationServicing
    let compassService: any CompassServicing
    let geocodingService: any GeocodingServicing
    let addressResolver: any AddressResolving
    let photoLibraryService: any PhotoLibraryServicing
    let photoMetadataProvider: any PhotoMetadataProviding
    let overlayRenderer: any OverlayRendering
    let videoOverlayRenderer: any VideoOverlayRendering
    /// Somut tipler tutulur; Observation ile UI güncellemelerinin yayılması için gereklidir.
    let settingsStore: SettingsStore
    let brandingAssetStore: BrandingAssetStore

    init(
        cameraManager: any CameraManaging = CameraManager(),
        locationService: any LocationServicing = LocationService(),
        compassService: any CompassServicing = CompassService(),
        geocodingService: any GeocodingServicing = GeocodingService(),
        photoLibraryService: any PhotoLibraryServicing = PhotoLibraryService(),
        overlayRenderer: any OverlayRendering = OverlayRenderer(),
        videoOverlayRenderer: any VideoOverlayRendering = VideoOverlayRenderer(),
        settingsStore: SettingsStore = SettingsStore(),
        brandingAssetStore: BrandingAssetStore = BrandingAssetStore()
    ) {
        let addressResolver = AddressResolver(
            locationService: locationService,
            geocodingService: geocodingService
        )

        self.cameraManager = cameraManager
        self.locationService = locationService
        self.compassService = compassService
        self.geocodingService = geocodingService
        self.addressResolver = addressResolver
        self.photoLibraryService = photoLibraryService
        self.photoMetadataProvider = PhotoMetadataProvider(
            locationService: locationService,
            compassService: compassService,
            addressResolver: addressResolver
        )
        self.overlayRenderer = overlayRenderer
        self.videoOverlayRenderer = videoOverlayRenderer
        self.settingsStore = settingsStore
        self.brandingAssetStore = brandingAssetStore
    }
}

extension AppDependencies {

    func makeCameraViewModel() -> CameraViewModel {
        CameraViewModel(
            cameraManager: cameraManager,
            photoLibraryService: photoLibraryService,
            metadataProvider: photoMetadataProvider,
            overlayRenderer: overlayRenderer,
            videoOverlayRenderer: videoOverlayRenderer,
            settingsStore: settingsStore,
            brandingAssetStore: brandingAssetStore
        )
    }

    func makeLocationViewModel() -> LocationViewModel {
        LocationViewModel(
            locationService: locationService,
            compassService: compassService,
            addressResolver: addressResolver
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            settingsStore: settingsStore,
            brandingAssetStore: brandingAssetStore
        )
    }
}
