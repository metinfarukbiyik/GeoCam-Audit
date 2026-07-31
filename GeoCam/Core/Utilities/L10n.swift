//
//  L10n.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Uygulama içi çeviriler. Dil seçimi String Catalog’a bağlı kalmadan anında uygulanır.
nonisolated enum L10n {

    static func t(_ key: Key, _ language: AppLanguage) -> String {
        table[key]?[language] ?? table[key]?[.english] ?? key.rawValue
    }

    static func t(_ key: Key, _ language: AppLanguage, _ args: CVarArg...) -> String {
        String(format: t(key, language), locale: language.locale, arguments: args)
    }

    enum Key: String {
        // Settings
        case settingsTitle
        case settingsDone
        case settingsLanguage
        case settingsLanguageFooter
        case settingsCamera
        case settingsCameraFooter
        case settingsFrameRatio
        case settingsSaveOriginal
        case settingsAppWatermark
        case watermarkAuthenticity
        case settingsJobInfo
        case settingsJobInfoFooter
        case settingsClearJobInfo
        case settingsOverlayFields
        case settingsBranding
        case settingsBrandingToggle
        case settingsBrandNamePlaceholder
        case settingsBrandFont
        case settingsBrandColor
        case settingsBrandIcon
        case settingsBrandPreview
        case settingsBrandFooter
        case settingsChooseLogo
        case settingsChangeLogo
        case settingsRemoveLogo
        case settingsAppearance
        case settingsAppearanceFooter
        case settingsLayout
        case settingsTheme
        case settingsFont
        case settingsTextSize
        case settingsContact
        case settingsContactFooter
        case settingsSendEmail
        case settingsReset
        case settingsDeveloperCredit

        // Camera / capture
        case capturePhoto
        case captureVideo
        case capturePhotoAccessibility
        case captureRecordStart
        case captureRecordStop
        case captureSwitchCamera
        case captureOpenPhotos
        case captureFlash
        case captureLight
        case captureSettingsMenu
        case captureJobInfo
        case captureJobInfoHintEmpty
        case captureJobInfoHintFilled
        case capturePhotoSaved
        case capturePhotosSaved
        case captureVideoSaved
        case captureProcessingOne
        case captureProcessingMany
        case captureQueueFull
        case captureVideoProcessing
        case captureCameraPermissionTitle
        case captureCameraPermissionMessage
        case captureOpenSettings

        // Location
        case locationSearching
        case locationDenied
        case locationSettings

        // Job info
        case jobSheetDone
        case jobWorkOrderPrompt
        case jobSitePrompt
        case jobSubjectPrompt
        case jobSheetFooter

        // Fields
        case fieldDate
        case fieldTime
        case fieldAddress
        case fieldCoordinates
        case fieldAltitude
        case fieldHeading
        case fieldAccuracy
        case fieldWorkOrder
        case fieldSiteID
        case fieldJobSubject
        case fieldShortLocation
        case fieldShortCoordinate
        case fieldShortAltitude
        case fieldShortHeading
        case fieldShortGPS
        case prefixWorkOrder
        case prefixSite
        case prefixNote

        // Layout / theme / size titles
        case layoutCard
        case layoutCompact
        case layoutBanner
        case layoutMinimal
        case layoutPoster
        case layoutSplit
        case layoutCapsule
        case themeSystem
        case themeLight
        case themeDark
        case fontStandard
        case fontRounded
        case fontMonospaced
        case fontSerif
        case sizeSmall
        case sizeMedium
        case sizeLarge

        // Brand fonts / icons (subset used in UI titles)
        case brandFontRounded
        case brandFontSerif
        case brandFontMonospaced
        case brandFontStandard
        case brandFontCondensed
        case brandColorWhite
        case brandColorYellow
        case brandColorOrange
        case brandColorGreen
        case brandColorMint
        case brandColorCyan
        case brandColorBlue
        case brandColorPink
        case brandColorRed
        case brandIconNone
        case brandIconBuilding
        case brandIconHammer
        case brandIconWrench
        case brandIconHouse
        case brandIconMap
        case brandIconCamera
        case brandIconSeal
        case brandIconStar
        case brandIconBriefcase
        case brandIconGear
        case brandIconLeaf
        case brandIconBolt
        case brandIconShield
        case brandIconLocation
        case brandIconCheckmark
        case brandLogoHint

        // Errors
        case errorCameraPermission
        case errorCameraPermissionHint
        case errorCameraUnavailable
        case errorCameraConfig
        case errorCameraCapture
        case errorCameraSwitch
        case errorCameraRecording
        case errorTryAgain
        case settingsSupport
        case settingsContactLink
        case errorLocationPermission
        case errorLocationPermissionHint
        case errorLocationDisabled
        case errorLocationDisabledHint
        case errorLocationUnavailable
        case errorGeocoding
        case errorGeocodingHint
        case errorPhotosPermission
        case errorPhotosPermissionHint
        case errorPhotosSave
        case errorPhotosRender
        case errorVideoUnsupported
        case errorVideoExport
        case mailFeedbackSubject
    }

    // MARK: - Table

    private static let table: [Key: [AppLanguage: String]] = [
        .settingsTitle: [
            .turkish: "Ayarlar", .english: "Settings", .spanish: "Ajustes", .german: "Einstellungen"
        ],
        .settingsDone: [
            .turkish: "Bitti", .english: "Done", .spanish: "Listo", .german: "Fertig"
        ],
        .settingsLanguage: [
            .turkish: "Dil", .english: "Language", .spanish: "Idioma", .german: "Sprache"
        ],
        .settingsLanguageFooter: [
            .turkish: "Arayüz ve bilgi katmanı metinleri seçilen dile göre güncellenir.",
            .english: "Interface and overlay texts update to the selected language.",
            .spanish: "La interfaz y los textos de la capa se actualizan al idioma seleccionado.",
            .german: "Oberfläche und Overlay-Texte werden an die gewählte Sprache angepasst."
        ],
        .settingsCamera: [
            .turkish: "Kamera", .english: "Camera", .spanish: "Cámara", .german: "Kamera"
        ],
        .settingsCameraFooter: [
            .turkish: "9:16 tam ekran, 4:3 çerçeveli önizleme sunar. Orijinali de kaydet aynı oranda damgasız kopya yazar. Damgalı çıktıya sağ altta zorunlu GeoCam filigranı (uygulama adı + orijinal kayıt) eklenir; ileride ücretli planda kaldırılabilir.",
            .english: "9:16 is full-screen; 4:3 shows a framed preview. Save Original writes an unstamped copy at the same ratio. Stamped media always get a GeoCam watermark (app name + authentic record); removable later with a paid plan.",
            .spanish: "9:16 es pantalla completa; 4:3 muestra un marco. Guardar original crea una copia sin sello. El contenido sellado lleva siempre la marca GeoCam (nombre + registro auténtico); más adelante se podrá quitar con un plan de pago.",
            .german: "9:16 ist Vollbild; 4:3 zeigt einen Rahmen. Original speichern schreibt eine ungestempelte Kopie. Gestempelte Medien erhalten immer das GeoCam-Wasserzeichen (App-Name + authentischer Nachweis); später per bezahltem Plan entfernbar."
        ],
        .settingsFrameRatio: [
            .turkish: "Çerçeve Oranı", .english: "Aspect Ratio", .spanish: "Proporción", .german: "Seitenverhältnis"
        ],
        .settingsSaveOriginal: [
            .turkish: "Orijinali de Kaydet", .english: "Also Save Original", .spanish: "Guardar también original", .german: "Auch Original speichern"
        ],
        .settingsAppWatermark: [
            .turkish: "GeoCam Filigranı", .english: "GeoCam Watermark", .spanish: "Marca de agua GeoCam", .german: "GeoCam-Wasserzeichen"
        ],
        .watermarkAuthenticity: [
            .turkish: "Orijinal saha kaydı",
            .english: "Authentic field record",
            .spanish: "Registro de campo auténtico",
            .german: "Authentischer Feldnachweis"
        ],
        .settingsJobInfo: [
            .turkish: "İş Bilgisi", .english: "Job Info", .spanish: "Info del trabajo", .german: "Auftragsinfo"
        ],
        .settingsJobInfoFooter: [
            .turkish: "İş emri, site kimliği ve not; canlı önizlemede ve kaydedilen fotoğrafta bilgi katmanına eklenir. Aynı işte birden fazla çekim için değerler saklanır.",
            .english: "Work order, site ID and note appear on the live overlay and stamped photos. Values persist for multiple shots on the same job.",
            .spanish: "La orden, el ID del sitio y la nota aparecen en la capa y en las fotos. Los valores se conservan para varias tomas del mismo trabajo.",
            .german: "Auftrag, Standort-ID und Notiz erscheinen im Overlay und auf Fotos. Werte bleiben für mehrere Aufnahmen desselben Jobs erhalten."
        ],
        .settingsClearJobInfo: [
            .turkish: "İş Bilgisini Temizle", .english: "Clear Job Info", .spanish: "Borrar info del trabajo", .german: "Auftragsinfo löschen"
        ],
        .settingsOverlayFields: [
            .turkish: "Gösterilecek Bilgiler", .english: "Visible Fields", .spanish: "Campos visibles", .german: "Angezeigte Felder"
        ],
        .settingsBranding: [
            .turkish: "Marka", .english: "Brand", .spanish: "Marca", .german: "Marke"
        ],
        .settingsBrandingToggle: [
            .turkish: "Fotoğrafa Marka Ekle", .english: "Add Brand to Photo", .spanish: "Añadir marca a la foto", .german: "Marke auf Foto setzen"
        ],
        .settingsBrandNamePlaceholder: [
            .turkish: "Şirket / Marka Adı", .english: "Company / Brand Name", .spanish: "Empresa / marca", .german: "Firma / Markenname"
        ],
        .settingsBrandFont: [
            .turkish: "Marka Yazı Tipi", .english: "Brand Font", .spanish: "Fuente de marca", .german: "Markenschrift"
        ],
        .settingsBrandColor: [
            .turkish: "Marka Rengi", .english: "Brand Color", .spanish: "Color de marca", .german: "Markenfarbe"
        ],
        .settingsBrandIcon: [
            .turkish: "Marka İkonu", .english: "Brand Icon", .spanish: "Icono de marca", .german: "Markensymbol"
        ],
        .settingsBrandPreview: [
            .turkish: "Marka Önizleme", .english: "Brand Preview", .spanish: "Vista previa", .german: "Markenvorschau"
        ],
        .settingsBrandFooter: [
            .turkish: "Logo veya ikon ile marka adı, canlı önizlemede ve kaydedilen fotoğrafta bilgi katmanının en üstünde görünür. Özel logo seçildiğinde ikon yerine logo kullanılır.",
            .english: "Logo or icon with brand name appears at the top of the live and stamped overlay. A custom logo replaces the icon.",
            .spanish: "El logo o icono con el nombre aparece arriba en la capa. Un logo personalizado sustituye al icono.",
            .german: "Logo oder Symbol mit Markennamen erscheint oben im Overlay. Ein eigenes Logo ersetzt das Symbol."
        ],
        .settingsChooseLogo: [
            .turkish: "Logo Seç", .english: "Choose Logo", .spanish: "Elegir logo", .german: "Logo wählen"
        ],
        .settingsChangeLogo: [
            .turkish: "Logoyu Değiştir", .english: "Change Logo", .spanish: "Cambiar logo", .german: "Logo ändern"
        ],
        .settingsRemoveLogo: [
            .turkish: "Logoyu Kaldır", .english: "Remove Logo", .spanish: "Quitar logo", .german: "Logo entfernen"
        ],
        .settingsAppearance: [
            .turkish: "Görünüm", .english: "Appearance", .spanish: "Apariencia", .german: "Darstellung"
        ],
        .settingsAppearanceFooter: [
            .turkish: "Tasarım seçimi kamera önizlemesine anında yansır. Bilgi katmanını parmağınızla sürükleyerek fotoğraftaki yerini değiştirebilirsiniz.",
            .english: "Layout changes apply instantly on the camera preview. Drag the info overlay to reposition it on the photo.",
            .spanish: "El diseño se aplica al instante en la vista previa. Arrastra la capa para reposicionarla.",
            .german: "Layout-Änderungen gelten sofort in der Vorschau. Ziehen Sie das Overlay, um es zu positionieren."
        ],
        .settingsLayout: [
            .turkish: "Katman Tasarımı", .english: "Overlay Layout", .spanish: "Diseño de capa", .german: "Overlay-Layout"
        ],
        .settingsTheme: [
            .turkish: "Tema", .english: "Theme", .spanish: "Tema", .german: "Design"
        ],
        .settingsFont: [
            .turkish: "Yazı Tipi", .english: "Font", .spanish: "Fuente", .german: "Schriftart"
        ],
        .settingsTextSize: [
            .turkish: "Metin Boyutu", .english: "Text Size", .spanish: "Tamaño de texto", .german: "Textgröße"
        ],
        .settingsContact: [
            .turkish: "İletişim", .english: "Contact", .spanish: "Contacto", .german: "Kontakt"
        ],
        .settingsContactFooter: [
            .turkish: "Hata bildirimi ve iyileştirme önerileriniz için %@ adresine yazabilirsiniz.",
            .english: "Write to %@ for bug reports and improvement ideas.",
            .spanish: "Escriba a %@ para reportes y sugerencias.",
            .german: "Schreiben Sie an %@ für Fehlerberichte und Verbesserungsvorschläge."
        ],
        .settingsSendEmail: [
            .turkish: "E-posta Gönder", .english: "Send Email", .spanish: "Enviar correo", .german: "E-Mail senden"
        ],
        .settingsReset: [
            .turkish: "Varsayılana Dön", .english: "Reset to Defaults", .spanish: "Restablecer", .german: "Zurücksetzen"
        ],
        .settingsDeveloperCredit: [
            .turkish: "tarafından geliştirilmiştir.",
            .english: "developed this app.",
            .spanish: "desarrolló esta app.",
            .german: "hat diese App entwickelt."
        ],

        .capturePhoto: [
            .turkish: "Fotoğraf", .english: "Photo", .spanish: "Foto", .german: "Foto"
        ],
        .captureVideo: [
            .turkish: "Video", .english: "Video", .spanish: "Vídeo", .german: "Video"
        ],
        .capturePhotoAccessibility: [
            .turkish: "Fotoğraf çek", .english: "Take photo", .spanish: "Tomar foto", .german: "Foto aufnehmen"
        ],
        .captureRecordStart: [
            .turkish: "Kaydı başlat", .english: "Start recording", .spanish: "Iniciar grabación", .german: "Aufnahme starten"
        ],
        .captureRecordStop: [
            .turkish: "Kaydı durdur", .english: "Stop recording", .spanish: "Detener grabación", .german: "Aufnahme stoppen"
        ],
        .captureSwitchCamera: [
            .turkish: "Kamerayı değiştir", .english: "Switch camera", .spanish: "Cambiar cámara", .german: "Kamera wechseln"
        ],
        .captureOpenPhotos: [
            .turkish: "Fotoğraflar'ı aç", .english: "Open Photos", .spanish: "Abrir Fotos", .german: "Fotos öffnen"
        ],
        .captureFlash: [
            .turkish: "Flaş modu", .english: "Flash mode", .spanish: "Modo flash", .german: "Blitzmodus"
        ],
        .captureLight: [
            .turkish: "Işık modu", .english: "Light mode", .spanish: "Modo de luz", .german: "Lichtmodus"
        ],
        .captureSettingsMenu: [
            .turkish: "Ayarlar menüsü", .english: "Settings menu", .spanish: "Menú de ajustes", .german: "Einstellungsmenü"
        ],
        .captureJobInfo: [
            .turkish: "İş bilgisi", .english: "Job info", .spanish: "Info del trabajo", .german: "Auftragsinfo"
        ],
        .captureJobInfoHintEmpty: [
            .turkish: "İş emri veya site kimliği ekle",
            .english: "Add work order or site ID",
            .spanish: "Añadir orden o ID de sitio",
            .german: "Auftrag oder Standort-ID hinzufügen"
        ],
        .captureJobInfoHintFilled: [
            .turkish: "İş bilgisi dolu; düzenlemek için dokunun",
            .english: "Job info set; tap to edit",
            .spanish: "Info del trabajo lista; toque para editar",
            .german: "Auftragsinfo gesetzt; tippen zum Bearbeiten"
        ],
        .capturePhotoSaved: [
            .turkish: "Fotoğraf kaydedildi", .english: "Photo saved", .spanish: "Foto guardada", .german: "Foto gespeichert"
        ],
        .capturePhotosSaved: [
            .turkish: "%d fotoğraf kaydedildi", .english: "%d photos saved", .spanish: "%d fotos guardadas", .german: "%d Fotos gespeichert"
        ],
        .captureVideoSaved: [
            .turkish: "Video kaydedildi", .english: "Video saved", .spanish: "Vídeo guardado", .german: "Video gespeichert"
        ],
        .captureProcessingOne: [
            .turkish: "1 fotoğraf işleniyor…", .english: "Processing 1 photo…", .spanish: "Procesando 1 foto…", .german: "1 Foto wird verarbeitet…"
        ],
        .captureProcessingMany: [
            .turkish: "%d fotoğraf işleniyor…", .english: "Processing %d photos…", .spanish: "Procesando %d fotos…", .german: "%d Fotos werden verarbeitet…"
        ],
        .captureQueueFull: [
            .turkish: "Kuyruk dolu, biraz bekleyin",
            .english: "Queue full, please wait",
            .spanish: "Cola llena, espere",
            .german: "Warteschlange voll, bitte warten"
        ],
        .captureVideoProcessing: [
            .turkish: "Video işleniyor…", .english: "Processing video…", .spanish: "Procesando vídeo…", .german: "Video wird verarbeitet…"
        ],
        .captureCameraPermissionTitle: [
            .turkish: "Kamera Erişimi Gerekli",
            .english: "Camera Access Required",
            .spanish: "Se requiere acceso a la cámara",
            .german: "Kamerazugriff erforderlich"
        ],
        .captureCameraPermissionMessage: [
            .turkish: "Fotoğraf çekebilmek için Ayarlar'dan kamera erişimine izin verin.",
            .english: "Allow camera access in Settings to take photos.",
            .spanish: "Permita el acceso a la cámara en Ajustes para tomar fotos.",
            .german: "Erlauben Sie den Kamerazugriff in den Einstellungen."
        ],
        .captureOpenSettings: [
            .turkish: "Ayarları Aç", .english: "Open Settings", .spanish: "Abrir Ajustes", .german: "Einstellungen öffnen"
        ],

        .locationSearching: [
            .turkish: "Konum aranıyor", .english: "Searching location", .spanish: "Buscando ubicación", .german: "Standort wird gesucht"
        ],
        .locationDenied: [
            .turkish: "Konum erişimi kapalı", .english: "Location access off", .spanish: "Ubicación desactivada", .german: "Standortzugriff aus"
        ],
        .locationSettings: [
            .turkish: "Ayarlar", .english: "Settings", .spanish: "Ajustes", .german: "Einstellungen"
        ],

        .jobSheetDone: [
            .turkish: "Tamam", .english: "OK", .spanish: "OK", .german: "OK"
        ],
        .jobWorkOrderPrompt: [
            .turkish: "Örn. WO-2026-0142", .english: "e.g. WO-2026-0142", .spanish: "ej. WO-2026-0142", .german: "z. B. WO-2026-0142"
        ],
        .jobSitePrompt: [
            .turkish: "Örn. TR-TBZ-042", .english: "e.g. TR-TBZ-042", .spanish: "ej. TR-TBZ-042", .german: "z. B. TR-TBZ-042"
        ],
        .jobSubjectPrompt: [
            .turkish: "Örn. Cephe kontrolü", .english: "e.g. Facade inspection", .spanish: "ej. Inspección de fachada", .german: "z. B. Fassadenkontrolle"
        ],
        .jobSheetFooter: [
            .turkish: "Bu bilgiler sonraki çekimlerde katmana basılır. Alanı katmanda gizlemek için Ayarlar’daki ilgili anahtarı kapatın.",
            .english: "This info is stamped on the next shots. Hide a field by turning off its switch in Settings.",
            .spanish: "Esta info se sella en las siguientes fotos. Oculte un campo desactivándolo en Ajustes.",
            .german: "Diese Infos werden auf die nächsten Aufnahmen gestempelt. Felder in den Einstellungen ausblenden."
        ],

        .fieldDate: [
            .turkish: "Tarih", .english: "Date", .spanish: "Fecha", .german: "Datum"
        ],
        .fieldTime: [
            .turkish: "Saat", .english: "Time", .spanish: "Hora", .german: "Uhrzeit"
        ],
        .fieldAddress: [
            .turkish: "Adres", .english: "Address", .spanish: "Dirección", .german: "Adresse"
        ],
        .fieldCoordinates: [
            .turkish: "Koordinatlar", .english: "Coordinates", .spanish: "Coordenadas", .german: "Koordinaten"
        ],
        .fieldAltitude: [
            .turkish: "Rakım", .english: "Altitude", .spanish: "Altitud", .german: "Höhe"
        ],
        .fieldHeading: [
            .turkish: "Pusula Yönü", .english: "Compass", .spanish: "Brújula", .german: "Kompass"
        ],
        .fieldAccuracy: [
            .turkish: "GPS Hassasiyeti", .english: "GPS Accuracy", .spanish: "Precisión GPS", .german: "GPS-Genauigkeit"
        ],
        .fieldWorkOrder: [
            .turkish: "İş Emri", .english: "Work Order", .spanish: "Orden de trabajo", .german: "Arbeitsauftrag"
        ],
        .fieldSiteID: [
            .turkish: "Site ID", .english: "Site ID", .spanish: "ID del sitio", .german: "Standort-ID"
        ],
        .fieldJobSubject: [
            .turkish: "Konu / Not", .english: "Subject / Note", .spanish: "Asunto / Nota", .german: "Betreff / Notiz"
        ],
        .fieldShortLocation: [
            .turkish: "Konum", .english: "Location", .spanish: "Ubicación", .german: "Ort"
        ],
        .fieldShortCoordinate: [
            .turkish: "Koordinat", .english: "Coords", .spanish: "Coords", .german: "Koord."
        ],
        .fieldShortAltitude: [
            .turkish: "Rakım", .english: "Alt", .spanish: "Alt", .german: "Höhe"
        ],
        .fieldShortHeading: [
            .turkish: "Yön", .english: "Heading", .spanish: "Rumbo", .german: "Richtung"
        ],
        .fieldShortGPS: [
            .turkish: "GPS", .english: "GPS", .spanish: "GPS", .german: "GPS"
        ],
        .prefixWorkOrder: [
            .turkish: "İE", .english: "WO", .spanish: "OT", .german: "AA"
        ],
        .prefixSite: [
            .turkish: "Site", .english: "Site", .spanish: "Sitio", .german: "Site"
        ],
        .prefixNote: [
            .turkish: "Not", .english: "Note", .spanish: "Nota", .german: "Notiz"
        ],

        .layoutCard: [.turkish: "Kart", .english: "Card", .spanish: "Tarjeta", .german: "Karte"],
        .layoutCompact: [.turkish: "Kompakt", .english: "Compact", .spanish: "Compacto", .german: "Kompakt"],
        .layoutBanner: [.turkish: "Şerit", .english: "Banner", .spanish: "Banner", .german: "Banner"],
        .layoutMinimal: [.turkish: "Sade", .english: "Minimal", .spanish: "Minimal", .german: "Minimal"],
        .layoutPoster: [.turkish: "Poster", .english: "Poster", .spanish: "Póster", .german: "Poster"],
        .layoutSplit: [.turkish: "İkili", .english: "Split", .spanish: "Dividido", .german: "Geteilt"],
        .layoutCapsule: [.turkish: "Kapsül", .english: "Capsule", .spanish: "Cápsula", .german: "Kapsel"],
        .themeSystem: [.turkish: "Sistem", .english: "System", .spanish: "Sistema", .german: "System"],
        .themeLight: [.turkish: "Açık", .english: "Light", .spanish: "Claro", .german: "Hell"],
        .themeDark: [.turkish: "Koyu", .english: "Dark", .spanish: "Oscuro", .german: "Dunkel"],
        .fontStandard: [.turkish: "Standart", .english: "Standard", .spanish: "Estándar", .german: "Standard"],
        .fontRounded: [.turkish: "Yumuşak", .english: "Rounded", .spanish: "Redondeada", .german: "Abgerundet"],
        .fontMonospaced: [.turkish: "Eşit Aralıklı", .english: "Monospaced", .spanish: "Monoespaciada", .german: "Monospace"],
        .fontSerif: [.turkish: "Serif", .english: "Serif", .spanish: "Serif", .german: "Serif"],
        .sizeSmall: [.turkish: "Küçük", .english: "Small", .spanish: "Pequeño", .german: "Klein"],
        .sizeMedium: [.turkish: "Orta", .english: "Medium", .spanish: "Mediano", .german: "Mittel"],
        .sizeLarge: [.turkish: "Büyük", .english: "Large", .spanish: "Grande", .german: "Groß"],

        .brandFontRounded: [.turkish: "Yuvarlak", .english: "Rounded", .spanish: "Redondeada", .german: "Rund"],
        .brandFontSerif: [.turkish: "Serif", .english: "Serif", .spanish: "Serif", .german: "Serif"],
        .brandFontMonospaced: [.turkish: "Eşit Aralıklı", .english: "Monospaced", .spanish: "Monoespaciada", .german: "Monospace"],
        .brandFontStandard: [.turkish: "Standart", .english: "Standard", .spanish: "Estándar", .german: "Standard"],
        .brandFontCondensed: [.turkish: "Sıkışık", .english: "Condensed", .spanish: "Condensada", .german: "Kondensiert"],
        .brandColorWhite: [.turkish: "Beyaz", .english: "White", .spanish: "Blanco", .german: "Weiß"],
        .brandColorYellow: [.turkish: "Sarı", .english: "Yellow", .spanish: "Amarillo", .german: "Gelb"],
        .brandColorOrange: [.turkish: "Turuncu", .english: "Orange", .spanish: "Naranja", .german: "Orange"],
        .brandColorGreen: [.turkish: "Yeşil", .english: "Green", .spanish: "Verde", .german: "Grün"],
        .brandColorMint: [.turkish: "Nane", .english: "Mint", .spanish: "Menta", .german: "Minze"],
        .brandColorCyan: [.turkish: "Camgöbeği", .english: "Cyan", .spanish: "Cian", .german: "Cyan"],
        .brandColorBlue: [.turkish: "Mavi", .english: "Blue", .spanish: "Azul", .german: "Blau"],
        .brandColorPink: [.turkish: "Pembe", .english: "Pink", .spanish: "Rosa", .german: "Rosa"],
        .brandColorRed: [.turkish: "Kırmızı", .english: "Red", .spanish: "Rojo", .german: "Rot"],
        .brandIconNone: [.turkish: "Yok", .english: "None", .spanish: "Ninguno", .german: "Keins"],
        .brandIconBuilding: [.turkish: "Bina", .english: "Building", .spanish: "Edificio", .german: "Gebäude"],
        .brandIconHammer: [.turkish: "Çekiç", .english: "Hammer", .spanish: "Martillo", .german: "Hammer"],
        .brandIconWrench: [.turkish: "Tamir", .english: "Tools", .spanish: "Herramientas", .german: "Werkzeug"],
        .brandIconHouse: [.turkish: "Ev", .english: "Home", .spanish: "Casa", .german: "Haus"],
        .brandIconMap: [.turkish: "Harita", .english: "Map", .spanish: "Mapa", .german: "Karte"],
        .brandIconCamera: [.turkish: "Kamera", .english: "Camera", .spanish: "Cámara", .german: "Kamera"],
        .brandIconSeal: [.turkish: "Onay", .english: "Verified", .spanish: "Verificado", .german: "Geprüft"],
        .brandIconStar: [.turkish: "Yıldız", .english: "Star", .spanish: "Estrella", .german: "Stern"],
        .brandIconBriefcase: [.turkish: "Çanta", .english: "Briefcase", .spanish: "Maletín", .german: "Aktenkoffer"],
        .brandIconGear: [.turkish: "Dişli", .english: "Gear", .spanish: "Engranaje", .german: "Zahnrad"],
        .brandIconLeaf: [.turkish: "Yaprak", .english: "Leaf", .spanish: "Hoja", .german: "Blatt"],
        .brandIconBolt: [.turkish: "Şimşek", .english: "Bolt", .spanish: "Rayo", .german: "Blitz"],
        .brandIconShield: [.turkish: "Kalkan", .english: "Shield", .spanish: "Escudo", .german: "Schild"],
        .brandIconLocation: [.turkish: "Konum", .english: "Location", .spanish: "Ubicación", .german: "Standort"],
        .brandIconCheckmark: [.turkish: "Tik", .english: "Check", .spanish: "Check", .german: "Häkchen"],
        .brandLogoHint: [
            .turkish: "Özel logo seçiliyken ikon gizlenir.",
            .english: "Icon is hidden when a custom logo is selected.",
            .spanish: "El icono se oculta si hay un logo personalizado.",
            .german: "Das Symbol wird bei eigenem Logo ausgeblendet."
        ],

        .errorCameraPermission: [
            .turkish: "Kamera erişimi reddedildi.",
            .english: "Camera access denied.",
            .spanish: "Acceso a la cámara denegado.",
            .german: "Kamerazugriff verweigert."
        ],
        .errorCameraPermissionHint: [
            .turkish: "Ayarlar > %@ bölümünden kamera erişimine izin verin.",
            .english: "Allow camera access in Settings > %@.",
            .spanish: "Permita la cámara en Ajustes > %@.",
            .german: "Erlauben Sie die Kamera unter Einstellungen > %@."
        ],
        .errorCameraUnavailable: [
            .turkish: "Kullanılabilir bir kamera bulunamadı.",
            .english: "No available camera found.",
            .spanish: "No se encontró una cámara disponible.",
            .german: "Keine verfügbare Kamera gefunden."
        ],
        .errorTryAgain: [
            .turkish: "Lütfen tekrar deneyin.",
            .english: "Please try again.",
            .spanish: "Inténtelo de nuevo.",
            .german: "Bitte erneut versuchen."
        ],
        .settingsSupport: [
            .turkish: "Destek", .english: "Support", .spanish: "Soporte", .german: "Support"
        ],
        .settingsContactLink: [
            .turkish: "İletişime Geç", .english: "Contact Us", .spanish: "Contactar", .german: "Kontakt aufnehmen"
        ],
        .errorCameraConfig: [
            .turkish: "Kamera yapılandırılamadı.",
            .english: "Camera could not be configured.",
            .spanish: "No se pudo configurar la cámara.",
            .german: "Kamera konnte nicht konfiguriert werden."
        ],
        .errorCameraCapture: [
            .turkish: "Fotoğraf çekilemedi.",
            .english: "Could not capture photo.",
            .spanish: "No se pudo capturar la foto.",
            .german: "Foto konnte nicht aufgenommen werden."
        ],
        .errorCameraSwitch: [
            .turkish: "Kamera değiştirilemedi.",
            .english: "Could not switch camera.",
            .spanish: "No se pudo cambiar la cámara.",
            .german: "Kamera konnte nicht gewechselt werden."
        ],
        .errorCameraRecording: [
            .turkish: "Video kaydı başarısız.",
            .english: "Video recording failed.",
            .spanish: "Falló la grabación de vídeo.",
            .german: "Videoaufnahme fehlgeschlagen."
        ],
        .errorLocationPermission: [
            .turkish: "Konum erişimi reddedildi.",
            .english: "Location access denied.",
            .spanish: "Acceso a la ubicación denegado.",
            .german: "Standortzugriff verweigert."
        ],
        .errorLocationPermissionHint: [
            .turkish: "Ayarlar > %@ bölümünden konum erişimine izin verin.",
            .english: "Allow location access in Settings > %@.",
            .spanish: "Permita la ubicación en Ajustes > %@.",
            .german: "Erlauben Sie den Standort unter Einstellungen > %@."
        ],
        .errorLocationDisabled: [
            .turkish: "Konum servisleri kapalı.",
            .english: "Location services are off.",
            .spanish: "Los servicios de ubicación están desactivados.",
            .german: "Ortungsdienste sind aus."
        ],
        .errorLocationDisabledHint: [
            .turkish: "Ayarlar > Gizlilik bölümünden konum servislerini açın.",
            .english: "Turn on Location Services in Settings > Privacy.",
            .spanish: "Active Ubicación en Ajustes > Privacidad.",
            .german: "Aktivieren Sie Ortungsdienste unter Einstellungen > Datenschutz."
        ],
        .errorLocationUnavailable: [
            .turkish: "Konum bilgisi alınamadı.",
            .english: "Location unavailable.",
            .spanish: "Ubicación no disponible.",
            .german: "Standort nicht verfügbar."
        ],
        .errorGeocoding: [
            .turkish: "Adres bilgisi çözümlenemedi.",
            .english: "Address could not be resolved.",
            .spanish: "No se pudo resolver la dirección.",
            .german: "Adresse konnte nicht aufgelöst werden."
        ],
        .errorGeocodingHint: [
            .turkish: "Adres yerine koordinatlar gösterilecektir.",
            .english: "Coordinates will be shown instead of the address.",
            .spanish: "Se mostrarán coordenadas en lugar de la dirección.",
            .german: "Statt der Adresse werden Koordinaten angezeigt."
        ],
        .errorPhotosPermission: [
            .turkish: "Fotoğraflar erişimi reddedildi.",
            .english: "Photos access denied.",
            .spanish: "Acceso a Fotos denegado.",
            .german: "Fotos-Zugriff verweigert."
        ],
        .errorPhotosPermissionHint: [
            .turkish: "Ayarlar > %@ bölümünden Fotoğraflar erişimine izin verin.",
            .english: "Allow Photos access in Settings > %@.",
            .spanish: "Permita Fotos en Ajustes > %@.",
            .german: "Erlauben Sie Fotos unter Einstellungen > %@."
        ],
        .errorPhotosSave: [
            .turkish: "Fotoğraf kaydedilemedi.",
            .english: "Could not save photo.",
            .spanish: "No se pudo guardar la foto.",
            .german: "Foto konnte nicht gespeichert werden."
        ],
        .errorPhotosRender: [
            .turkish: "Bilgi katmanı işlenemedi.",
            .english: "Could not render overlay.",
            .spanish: "No se pudo procesar la capa.",
            .german: "Overlay konnte nicht gerendert werden."
        ],
        .errorVideoUnsupported: [
            .turkish: "Video kaynağı desteklenmiyor.",
            .english: "Unsupported video source.",
            .spanish: "Fuente de vídeo no admitida.",
            .german: "Videoquelle nicht unterstützt."
        ],
        .errorVideoExport: [
            .turkish: "Video dışa aktarılamadı.",
            .english: "Could not export video.",
            .spanish: "No se pudo exportar el vídeo.",
            .german: "Video konnte nicht exportiert werden."
        ],
        .mailFeedbackSubject: [
            .turkish: "%@ Geri Bildirim",
            .english: "%@ Feedback",
            .spanish: "Comentarios de %@",
            .german: "%@ Feedback"
        ]
    ]
}
