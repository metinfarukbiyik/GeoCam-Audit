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
        static let developerName = "BIYIK.DEV"
        static let developerURL = URL(string: "https://biyik.dev")
        static let developerCreditSuffix = "tarafından geliştirilmiştir."
        static let supportEmail = "metin@biyik.dev"
    }

    enum ExternalLink {
        /// Sistemin Fotoğraflar uygulamasını açar.
        static let photosApp = URL(string: "photos-redirect://")

        /// Konu satırı hazır gelen destek e-postası.
        static var supportMail: URL? {
            var components = URLComponents()
            components.scheme = "mailto"
            components.path = Info.supportEmail
            components.queryItems = [
                URLQueryItem(name: "subject", value: "\(Info.appName) Geri Bildirim")
            ]

            return components.url
        }
    }

    enum Storage {
        static let overlaySettingsKey = "geocam.overlaySettings"
        static let brandingLogoFileName = "branding-logo.png"
    }

    /// Kurumsal iş bilgisi satır etiketleri (katmanda kısa gösterim).
    enum JobInfo {
        static let workOrderPrefix = "İE"
        static let siteIDPrefix = "Site"
        static let subjectPrefix = "Not"
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
