//
//  AppLanguage.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Uygulama içi dil seçenekleri (Türkçe + 3 yaygın dünya dili).
nonisolated enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case turkish = "tr"
    case english = "en"
    case spanish = "es"
    case german = "de"

    var id: String { rawValue }

    var locale: Locale { Locale(identifier: rawValue) }

    /// Seçicide kendi dilinde gösterilen ad.
    var nativeTitle: String {
        switch self {
        case .turkish: "Türkçe"
        case .english: "English"
        case .spanish: "Español"
        case .german: "Deutsch"
        }
    }

    func t(_ key: L10n.Key) -> String {
        L10n.t(key, self)
    }

    func t(_ key: L10n.Key, _ args: CVarArg...) -> String {
        String(format: L10n.t(key, self), locale: locale, arguments: args)
    }
}
