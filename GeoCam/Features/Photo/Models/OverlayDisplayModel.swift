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
    let detailRows: [Row]
    let textSize: OverlayTextSize

    init(metadata: PhotoMetadata, settings: OverlaySettings, branding: OverlayBranding?) {
        self.branding = branding
        self.textSize = settings.textSize
        self.addressText = settings.isEnabled(.address) ? metadata.placeText : nil
        self.detailRows = Self.makeDetailRows(metadata: metadata, settings: settings)
    }

    // MARK: - Private

    private static func makeDetailRows(metadata: PhotoMetadata, settings: OverlaySettings) -> [Row] {
        OverlayField.allCases.compactMap { field in
            guard field != .address,
                  settings.isEnabled(field),
                  let value = value(for: field, metadata: metadata, settings: settings)
            else { return nil }

            return Row(
                id: field.id,
                systemImage: field.systemImageName,
                title: shortTitle(for: field),
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
            stripped(settings.trimmedWorkOrder, prefix: AppConstants.JobInfo.workOrderPrefix)
        case .siteID:
            stripped(settings.trimmedSiteID, prefix: AppConstants.JobInfo.siteIDPrefix)
        case .jobSubject:
            stripped(settings.trimmedJobSubject, prefix: AppConstants.JobInfo.subjectPrefix)
        }
    }

    /// Kullanıcı alana "İE: …" yazdıysa tekrar etiket eklenmesin diye önek temizlenir.
    private static func stripped(_ value: String, prefix: String) -> String? {
        guard !value.isEmpty else { return nil }

        let colonPrefix = "\(prefix):"
        if value.lowercased().hasPrefix(colonPrefix.lowercased()) {
            let remainder = String(value.dropFirst(colonPrefix.count))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return remainder.isEmpty ? nil : remainder
        }

        return value
    }

    /// Satırlarda alan adlarının kısa karşılıkları kullanılır.
    private static func shortTitle(for field: OverlayField) -> String {
        switch field {
        case .date: "Tarih"
        case .time: "Saat"
        case .address: "Konum"
        case .coordinates: "Koordinat"
        case .altitude: "Rakım"
        case .heading: "Yön"
        case .accuracy: "GPS"
        case .workOrder: AppConstants.JobInfo.workOrderPrefix
        case .siteID: AppConstants.JobInfo.siteIDPrefix
        case .jobSubject: AppConstants.JobInfo.subjectPrefix
        }
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
