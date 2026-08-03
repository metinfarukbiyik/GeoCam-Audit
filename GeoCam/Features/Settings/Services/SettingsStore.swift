//
//  SettingsStore.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation
import OSLog

/// UserDefaults tabanlı tercih deposu.
@MainActor
@Observable
final class SettingsStore: SettingsStoring {

    private(set) var settings: OverlaySettings

    private let defaults: UserDefaults
    private let storageKey: String

    init(
        defaults: UserDefaults = .standard,
        storageKey: String = AppConstants.Storage.overlaySettingsKey
    ) {
        self.defaults = defaults
        self.storageKey = storageKey

        var loaded = Self.load(from: defaults, key: storageKey) ?? .default
        // Konum yalnızca doğrulanır. Çerçeveye sığdırma görüntüleme anında yapılır;
        // burada sıkıştırılırsa kullanıcının bıraktığı yer her açılışta kaybolur.
        loaded.position = loaded.position.sanitized()
        self.settings = loaded
    }

    func update(_ settings: OverlaySettings) {
        self.settings = settings
        persist(settings)
    }

    func resetToDefaults() {
        update(.default)
    }

    // MARK: - Persistence

    private func persist(_ settings: OverlaySettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: storageKey)
        } catch {
            AppLogger.settings.error("Ayarlar kaydedilemedi: \(error.localizedDescription, privacy: .public)")
        }
    }

    private static func load(from defaults: UserDefaults, key: String) -> OverlaySettings? {
        guard let data = defaults.data(forKey: key) else { return nil }

        do {
            return try JSONDecoder().decode(OverlaySettings.self, from: data)
        } catch {
            AppLogger.settings.error("Ayarlar okunamadı: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
