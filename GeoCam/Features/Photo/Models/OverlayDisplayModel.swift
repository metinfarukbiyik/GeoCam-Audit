//
//  OverlayDisplayModel.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Katman tasarımlarının ortak veri kaynağı.
/// Alan seçimi ve metin üretimi burada toplanır; tasarımlar yalnızca yerleşimden sorumludur.
nonisolated struct OverlayDisplayModel {

    struct Row: Identifiable {
        let id: String
        let systemImage: String
        let title: String
        /// Ham değer; etiket içermez (çift "İE: İE:" oluşumunu önlemek için).
        let value: String
        /// Compact gibi yalnızca değer gösteren düzenlerde `Başlık: değer` kullanılsın.
        let showsInlineLabel: Bool
        var tint: Color?

        /// Tek satırda güvenli gösterim; etiket bir kez eklenir.
        var displayText: String {
            showsInlineLabel ? "\(title): \(value)" : value
        }
    }

    let branding: OverlayBranding?
    /// Uzun olabileceği için diğer satırlardan ayrı ele alınan konum metni.
    let addressText: String?
    let addressTitle: String
    let detailRows: [Row]
    let textSize: OverlayTextSize

    init(metadata: PhotoMetadata, settings: OverlaySettings, branding: OverlayBranding?) {
        let language = settings.appLanguage
        self.branding = branding
        self.textSize = settings.textSize
        self.addressText = settings.isEnabled(.address) ? metadata.placeText : nil
        self.addressTitle = language.t(.fieldShortLocation)
        self.detailRows = Self.makeDetailRows(metadata: metadata, settings: settings, language: language)
    }

    // MARK: - Private

    private static func makeDetailRows(
        metadata: PhotoMetadata,
        settings: OverlaySettings,
        language: AppLanguage
    ) -> [Row] {
        OverlayField.allCases.compactMap { field in
            guard field != .address,
                  settings.isEnabled(field),
                  let value = value(for: field, metadata: metadata, settings: settings)
            else { return nil }

            return Row(
                id: field.id,
                systemImage: field.systemImageName,
                title: field.shortTitle(language: language),
                value: value,
                showsInlineLabel: field.isJobInfoField,
                tint: tint(for: field, metadata: metadata)
            )
        }
    }

    private static func value(
        for field: OverlayField,
        metadata: PhotoMetadata,
        settings: OverlaySettings
    ) -> String? {
        switch field {
        case .date: metadata.dateText
        case .time: metadata.timeText
        case .address: nil
        case .coordinates:
            // Adres satırı koordinatı yedek olarak gösteriyorsa tekrar edilmez.
            if settings.isEnabled(.address), metadata.addressText == nil {
                nil
            } else {
                metadata.coordinateText
            }
        case .altitude: metadata.altitudeText
        case .heading: metadata.headingText
        case .accuracy: metadata.accuracyText
        case .workOrder:
            stripped(settings.trimmedWorkOrder, prefixes: Self.prefixes(for: .prefixWorkOrder))
        case .siteID:
            stripped(settings.trimmedSiteID, prefixes: Self.prefixes(for: .prefixSite))
        case .jobSubject:
            stripped(settings.trimmedJobSubject, prefixes: Self.prefixes(for: .prefixNote))
        }
    }

    /// Dil değişince eski öneklerin çift yazılmaması için tüm dil varyantları temizlenir.
    private static func prefixes(for key: L10n.Key) -> [String] {
        AppLanguage.allCases.map { $0.t(key) }
    }

    /// Kullanıcı alana "İE: …" yazdıysa tekrar etiket eklenmesin diye önek temizlenir.
    private static func stripped(_ value: String, prefixes: [String]) -> String? {
        guard !value.isEmpty else { return nil }

        for prefix in prefixes {
            let colonPrefix = "\(prefix):"
            if value.lowercased().hasPrefix(colonPrefix.lowercased()) {
                let remainder = String(value.dropFirst(colonPrefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return remainder.isEmpty ? nil : remainder
            }
        }

        return value
    }

    private static func tint(for field: OverlayField, metadata: PhotoMetadata) -> Color? {
        guard field == .accuracy, let level = metadata.location?.accuracyLevel else { return nil }

        return switch level {
        case .high: .green
        case .moderate: .yellow
        case .low: .orange
        }
    }
}
