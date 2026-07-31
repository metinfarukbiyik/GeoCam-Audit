//
//  BrandingAssetStore.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import OSLog
import UIKit

/// Logoyu uygulama destek klasöründe PNG olarak saklar.
/// Görsel veriler UserDefaults için fazla büyüktür, bu yüzden dosya sistemi kullanılır.
@MainActor
@Observable
final class BrandingAssetStore: BrandingAssetStoring {

    private(set) var logo: UIImage?

    private let fileURL: URL?

    init(fileName: String = AppConstants.Storage.brandingLogoFileName) {
        fileURL = Self.makeFileURL(fileName: fileName)
        logo = Self.loadLogo(at: fileURL)
    }

    func updateLogo(_ image: UIImage?) {
        logo = image

        guard let fileURL else { return }

        do {
            guard let image, let data = image.pngData() else {
                try FileManager.default.removeItemIfExists(at: fileURL)
                return
            }

            try data.write(to: fileURL, options: .atomic)
        } catch {
            AppLogger.settings.error("Logo kaydedilemedi: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Private

    private static func makeFileURL(fileName: String) -> URL? {
        let fileManager = FileManager.default

        do {
            let directory = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            return directory.appendingPathComponent(fileName)
        } catch {
            AppLogger.settings.error("Logo klasörü hazırlanamadı: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private static func loadLogo(at url: URL?) -> UIImage? {
        guard let url, let data = try? Data(contentsOf: url) else { return nil }

        return UIImage(data: data)
    }
}
