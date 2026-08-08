//
//  OverlaySettings.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreGraphics
import Foundation

/// Bilgi katmanının ve uygulama görünümünün kullanıcı tercihleri.
nonisolated struct OverlaySettings: Equatable, Codable, Sendable {
    var enabledFields: Set<OverlayField>
    var layoutStyle: OverlayLayoutStyle
    var theme: AppTheme
    var fontStyle: OverlayFontStyle
    var textSize: OverlayTextSize
    /// Katmanın tamamına uygulanan geometrik küçültme oranı (parmakla ayarlanır).
    var overlayScale: CGFloat
    /// Bilgi katmanının yaslandığı kenar (yalnızca sol / sağ).
    var corner: OverlayCorner
    /// Kenar üzerindeki dikey konum (0 = üst, 1 = filigranın üstü).
    var verticalPosition: CGFloat
    var aspectRatio: CameraAspectRatio
    /// Arayüz ve katman metinleri dili.
    var appLanguage: AppLanguage
    /// Açıkken damgalı kopyaya ek olarak işlenmemiş orijinal de Fotoğraflar’a yazılır.
    var savesOriginalPhoto: Bool
    /// Kullanıcı tercihi; `allowsRemovingAppWatermark` kapalıyken yok sayılır.
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
        enabledFields: [.date, .time, .address, .coordinates, .altitude, .heading, .accuracy],
        layoutStyle: .minimal,
        theme: .system,
        fontStyle: .rounded,
        textSize: .medium,
        overlayScale: OverlayConstants.Scale.maximum,
        corner: .default,
        verticalPosition: OverlayConstants.VerticalPosition.defaultValue,
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

    /// Önceki varsayılan alan seti (rakım kapalıydı); açılışta bir kez tamamlanır.
    private static let legacyDefaultFieldsWithoutAltitude: Set<OverlayField> = [
        .date, .time, .address, .coordinates, .heading, .accuracy
    ]

    /// Metin yönü, seçili köşenin yatay tarafına göre belirlenir.
    var horizontalAlignment: OverlayHorizontalAlignment {
        corner.horizontalAlignment
    }

    func isEnabled(_ field: OverlayField) -> Bool {
        enabledFields.contains(field)
    }

    /// Aralık dışına çıkmış kayıtlara karşı güvenli ölçek.
    var resolvedScale: CGFloat {
        OverlayConstants.Scale.clamped(overlayScale)
    }

    /// Aralık dışına çıkmış dikey konum.
    var resolvedVerticalPosition: CGFloat {
        OverlayConstants.VerticalPosition.clamped(verticalPosition)
    }

    /// Damgalı çıktıya uygulama filigranı uygulanır mı?
    /// Bu sürümde her zaman açık; kapı açılınca kullanıcı tercihine düşer.
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
        overlayScale = try container.decodeIfPresent(CGFloat.self, forKey: .overlayScale)
            ?? fallback.overlayScale

        let legacyPosition = try container.decodeIfPresent(OverlayPosition.self, forKey: .position)?
            .sanitized()

        if let decodedCorner = try container.decodeIfPresent(OverlayCorner.self, forKey: .corner) {
            corner = decodedCorner
        } else {
            // Serbest konum döneminden kenara göç.
            let alignment = try container.decodeIfPresent(
                OverlayHorizontalAlignment.self,
                forKey: .horizontalAlignment
            ) ?? .leading
            if let legacyPosition {
                corner = OverlayCorner.migrating(from: legacyPosition, alignment: alignment)
            } else {
                corner = fallback.corner
            }

            // Yalnızca kenar öncesi kayıtlarda bir kez: eski varsayılan sete rakım eklenir.
            if enabledFields == Self.legacyDefaultFieldsWithoutAltitude {
                enabledFields.insert(.altitude)
            }
        }

        if let decodedVertical = try container.decodeIfPresent(CGFloat.self, forKey: .verticalPosition) {
            verticalPosition = OverlayConstants.VerticalPosition.clamped(decodedVertical)
        } else if let legacyPosition, !container.contains(.corner) {
            verticalPosition = OverlayConstants.VerticalPosition.clamped(legacyPosition.y)
        } else {
            // Eski alt-köşe kayıtları: dikey anahtar yoksa alta yakın varsayılan.
            verticalPosition = fallback.verticalPosition
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

    /// Eski anahtarlar yalnızca okunur; yeni kayıtlara yazılmaz.
    private enum CodingKeys: String, CodingKey {
        case enabledFields
        case layoutStyle
        case theme
        case fontStyle
        case textSize
        case overlayScale
        case corner
        case verticalPosition
        case horizontalAlignment
        case position
        case aspectRatio
        case appLanguage
        case savesOriginalPhoto
        case showsAppWatermark
        case showsBranding
        case brandName
        case brandFontStyle
        case brandAccentColor
        case brandIcon
        case workOrderNumber
        case siteID
        case jobSubject
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(enabledFields, forKey: .enabledFields)
        try container.encode(layoutStyle, forKey: .layoutStyle)
        try container.encode(theme, forKey: .theme)
        try container.encode(fontStyle, forKey: .fontStyle)
        try container.encode(textSize, forKey: .textSize)
        try container.encode(overlayScale, forKey: .overlayScale)
        try container.encode(corner, forKey: .corner)
        try container.encode(verticalPosition, forKey: .verticalPosition)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(appLanguage, forKey: .appLanguage)
        try container.encode(savesOriginalPhoto, forKey: .savesOriginalPhoto)
        try container.encode(showsAppWatermark, forKey: .showsAppWatermark)
        try container.encode(showsBranding, forKey: .showsBranding)
        try container.encode(brandName, forKey: .brandName)
        try container.encode(brandFontStyle, forKey: .brandFontStyle)
        try container.encode(brandAccentColor, forKey: .brandAccentColor)
        try container.encode(brandIcon, forKey: .brandIcon)
        try container.encode(workOrderNumber, forKey: .workOrderNumber)
        try container.encode(siteID, forKey: .siteID)
        try container.encode(jobSubject, forKey: .jobSubject)
    }
}
