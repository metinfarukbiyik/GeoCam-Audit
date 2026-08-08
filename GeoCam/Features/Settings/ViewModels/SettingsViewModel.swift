//
//  SettingsViewModel.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Observation
import UIKit

/// Ayarlar ekranının durumunu yöneten görünüm modeli.
/// Değişiklikler taslakta tutulur; yalnızca Bitti ile kalıcılaştırılır.
@MainActor
@Observable
final class SettingsViewModel {

    private let settingsStore: SettingsStore
    private let brandingAssetStore: BrandingAssetStore

    /// Ekranda düzenlenen geçici tercihler.
    var draft: OverlaySettings
    /// Taslak logo; Bitti’ye kadar disk / store’a yazılmaz.
    var draftLogo: UIImage?

    init(settingsStore: SettingsStore, brandingAssetStore: BrandingAssetStore) {
        self.settingsStore = settingsStore
        self.brandingAssetStore = brandingAssetStore
        self.draft = settingsStore.settings
        self.draftLogo = brandingAssetStore.logo
    }

    /// Sheet açılmadan önce kalıcı değerlerden taze taslak üretir.
    func prepareForPresentation() {
        draft = settingsStore.settings
        draftLogo = brandingAssetStore.logo
    }

    /// Taslağı kalıcı depoya yazar.
    func save() {
        settingsStore.update(draft)
        brandingAssetStore.updateLogo(draftLogo)
    }

    func updateDraftLogo(_ image: UIImage?) {
        draftLogo = image

        if image != nil {
            draft.showsBranding = true
        }
    }

    func resetDraftToDefaults() {
        draft = .default
        draftLogo = nil
    }
}
