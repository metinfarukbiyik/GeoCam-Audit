//
//  AppConstants.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Uygulama genelinde kullanılan sabitler.
nonisolated enum AppConstants {

    enum Info {
        static let appName = "GeoCam: Audit"
        /// Çekimlerin toplandığı Fotoğraflar albümü.
        static let photoAlbumName = "GeoCam"
        static let developerName = "BIYIK.DEV"
        static let developerURL = URL(string: "https://biyik.dev")
        static let supportEmail = "metin@biyik.dev"
    }

    enum ExternalLink {
        /// Sistemin Fotoğraflar uygulamasını açar.
        static let photosApp = URL(string: "photos-redirect://")

        /// App Store uygulama kimliği.
        static let appStoreID = "6797103829"

        /// App Store ürün sayfası.
        static let appStorePage = URL(
            string: "https://apps.apple.com/app/id\(appStoreID)"
        )

        /// App Store puan / yorum ekranı.
        static let appStoreReview = URL(
            string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
        )

        /// Konu satırı hazır gelen destek e-postası.
        static func supportMail(language: AppLanguage) -> URL? {
            var components = URLComponents()
            components.scheme = "mailto"
            components.path = Info.supportEmail
            components.queryItems = [
                URLQueryItem(
                    name: "subject",
                    value: language.t(.mailFeedbackSubject, Info.appName)
                )
            ]

            return components.url
        }
    }

    enum Storage {
        static let overlaySettingsKey = "geocam.overlaySettings"
        static let brandingLogoFileName = "branding-logo.png"
    }

    /// Uygulama davranış kapıları. Filigran bu sürümde her zaman uygulanır.
    enum Features {
        /// `true` olduğunda kullanıcı filigranı kapatabilir. Şu an kapalıdır.
        static let allowsRemovingAppWatermark = false
    }

    enum Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
    }

    enum Feedback {
        /// Bilgilendirme balonunun ekranda kalma süresi.
        static let toastDuration: TimeInterval = 2
        /// Markalı açılış ekranının görünür kalma süresi.
        static let splashDuration: TimeInterval = 1.25
    }
}
