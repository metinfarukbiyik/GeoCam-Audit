//
//  OverlaySettings.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Bilgi katmanının ve uygulama görünümünün kullanıcı tercihleri.
nonisolated struct OverlaySettings: Equatable, Codable, Sendable {
    var enabledFields: Set<OverlayField>
    var layoutStyle: OverlayLayoutStyle
    var theme: AppTheme
    var fontStyle: OverlayFontStyle
    var textSize: OverlayTextSize
    var position: OverlayPosition
    var aspectRatio: CameraAspectRatio
    /// Arayüz ve katman metinleri dili.
    var appLanguage: AppLanguage
    /// Açıkken damgalı kopyaya ek olarak işlenmemiş orijinal de Fotoğraflar’a yazılır.
    var savesOriginalPhoto: Bool
    /// Gelecekte Pro ile kapatılabilir; şimdilik `appliesAppWatermark` her zaman true döner.
    var showsAppWatermark: Bool
    var showsBranding: Bool
    var brandName: String
    var brandFontStyle: BrandFontStyle
    var brandAccentColor: BrandAccentColor
    var brandIcon: BrandIcon
    /// Kurumsal iş emri numarası (ör. WO-2026-0142).
    var workOrderNumber: String
    /// Saha / tesis kimliği.
    var siteID: String
    /// İş konusu veya serbest not.
    var jobSubject: String

    static let `default` = OverlaySettings(
        enabledFields: [.date, .time, .address, .coordinates, .heading, .accuracy],
        layoutStyle: .compact,
        theme: .system,
        fontStyle: .rounded,
        textSize: .medium,
        position: .default,
        aspectRatio: .wide,
        appLanguage: .turkish,
        savesOriginalPhoto: false,
        showsAppWatermark: true,
        showsBranding: false,
        brandName: "",
        brandFontStyle: .rounded,
        brandAccentColor: .white,
        brandIcon: .none,
        workOrderNumber: "",
        siteID: "",
        jobSubject: ""
    )

    /// Canlı konum kartında gösterilebilecek alanlar.
    static let liveLocationFields: Set<OverlayField> = [
        .address, .coordinates, .altitude, .heading, .accuracy
    ]

    /// Önceki sürümlerde kaydedilmiş varsayılan konumlar.
    private static let legacyDefaultPositions: [OverlayPosition] = [
        OverlayPosition(x: 0.5, y: 0.85),
        OverlayPosition(x: 0.18, y: 0.72)
    ]

    func isEnabled(_ field: OverlayField) -> Bool {
        enabledFields.contains(field)
    }

    /// Damgalı çıktıya uygulama filigranı uygulanır mı?
    /// Ücretsiz sürümde her zaman açık; Pro kapısı açılınca kullanıcı tercihine düşer.
    var appliesAppWatermark: Bool {
        AppConstants.Features.allowsRemovingAppWatermark ? showsAppWatermark : true
    }

    /// Canlı konum kartında en az bir alan açık mı?
    var hasVisibleLiveLocationFields: Bool {
        !enabledFields.isDisjoint(with: Self.liveLocationFields)
    }

    /// En az bir iş bilgisi metni dolu mu?
    var hasJobInfoContent: Bool {
        !trimmedWorkOrder.isEmpty || !trimmedSiteID.isEmpty || !trimmedJobSubject.isEmpty
    }

    var trimmedWorkOrder: String {
        workOrderNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedSiteID: String {
        siteID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedJobSubject: String {
        jobSubject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// İş emri, site ve konu alanlarını boşaltır; toggle durumuna dokunmaz.
    mutating func clearJobInfo() {
        workOrderNumber = ""
        siteID = ""
        jobSubject = ""
    }
}

nonisolated extension OverlaySettings {

    /// Eski sürümlerde kaydedilmiş tercihlerin yeni alanlar yüzünden silinmemesi için
    /// eksik anahtarlar varsayılan değerlerle tamamlanır.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = Self.default

        enabledFields = try container.decodeIfPresent(Set<OverlayField>.self, forKey: .enabledFields)
            ?? fallback.enabledFields
        layoutStyle = try container.decodeIfPresent(OverlayLayoutStyle.self, forKey: .layoutStyle)
            ?? fallback.layoutStyle
        theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? fallback.theme
        fontStyle = try container.decodeIfPresent(OverlayFontStyle.self, forKey: .fontStyle) ?? fallback.fontStyle
        textSize = try container.decodeIfPresent(OverlayTextSize.self, forKey: .textSize) ?? fallback.textSize
        let decodedPosition = try container.decodeIfPresent(OverlayPosition.self, forKey: .position)
        // Eski varsayılan konumlar yeni sol-üst + kenar boşluklu modele taşınır.
        if let decodedPosition, Self.legacyDefaultPositions.contains(decodedPosition) {
            position = fallback.position
        } else {
            position = decodedPosition ?? fallback.position
        }
        aspectRatio = try container.decodeIfPresent(CameraAspectRatio.self, forKey: .aspectRatio)
            ?? fallback.aspectRatio
        appLanguage = try container.decodeIfPresent(AppLanguage.self, forKey: .appLanguage)
            ?? fallback.appLanguage
        savesOriginalPhoto = try container.decodeIfPresent(Bool.self, forKey: .savesOriginalPhoto)
            ?? fallback.savesOriginalPhoto
        showsAppWatermark = try container.decodeIfPresent(Bool.self, forKey: .showsAppWatermark)
            ?? fallback.showsAppWatermark
        showsBranding = try container.decodeIfPresent(Bool.self, forKey: .showsBranding) ?? fallback.showsBranding
        brandName = try container.decodeIfPresent(String.self, forKey: .brandName) ?? fallback.brandName
        brandFontStyle = try container.decodeIfPresent(BrandFontStyle.self, forKey: .brandFontStyle)
            ?? fallback.brandFontStyle
        brandAccentColor = try container.decodeIfPresent(BrandAccentColor.self, forKey: .brandAccentColor)
            ?? fallback.brandAccentColor
        brandIcon = try container.decodeIfPresent(BrandIcon.self, forKey: .brandIcon) ?? fallback.brandIcon
        workOrderNumber = try container.decodeIfPresent(String.self, forKey: .workOrderNumber)
            ?? fallback.workOrderNumber
        siteID = try container.decodeIfPresent(String.self, forKey: .siteID) ?? fallback.siteID
        jobSubject = try container.decodeIfPresent(String.self, forKey: .jobSubject) ?? fallback.jobSubject
    }
}
