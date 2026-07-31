//
//  SettingsViewModel.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Observation
import UIKit

/// Ayarlar ekranının durumunu yöneten görünüm modeli.
/// Değerler store üzerinden okunur/yazılır; böylece Toggle gibi iç içe Binding'ler de kalıcılaşır.
@MainActor
@Observable
final class SettingsViewModel {

    private let settingsStore: SettingsStore
    private let brandingAssetStore: BrandingAssetStore

    var settings: OverlaySettings {
        get { settingsStore.settings }
        set { settingsStore.update(newValue) }
    }

    var logo: UIImage? { brandingAssetStore.logo }

    init(settingsStore: SettingsStore, brandingAssetStore: BrandingAssetStore) {
        self.settingsStore = settingsStore
        self.brandingAssetStore = brandingAssetStore
    }

    func updateLogo(_ image: UIImage?) {
        brandingAssetStore.updateLogo(image)

        // Logo eklendiğinde marka katmanı kullanıcıdan ayrıca onay beklemeden görünür olur.
        if image != nil, !settings.showsBranding {
            settings.showsBranding = true
        }
    }

    func resetToDefaults() {
        settingsStore.resetToDefaults()
        brandingAssetStore.updateLogo(nil)
    }
}
