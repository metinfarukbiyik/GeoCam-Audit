# GeoCam: Audit

Profesyonel saha / denetim kamerası. Çekilen fotoğraf ve videoya konum, adres, pusula, iş bilgisi ve markayı damgalar; sağ altta zorunlu GeoCam filigranı ile kaydın orijinalliğini vurgular.

Kullanıcı verisi cihaz dışına gönderilmez. Analitik, reklam, hesap ve bulut senkronizasyonu yoktur. (Tek istisna: adres çözümlemesi Apple'ın `CLGeocoder` servisini kullanır ve internet gerektirir — bkz. [Uyarı: “offline” ifadesi](#uyarı-offline-ifadesi).)

| | |
|---|---|
| Platform | iOS 17.0+ |
| Dil | Swift 6 |
| UI | SwiftUI |
| Mimari | MVVM + protocol servisler |
| Durum yönetimi | Observation (`@Observable`) |
| Asenkron | async/await, actor kuyruk |
| Uygulama içi dil | tr / en / es / de (`L10n`, anında geçiş) |
| Bundle ID | `metinbiyik.GeoCam` |
| Team ID | `4V29PYSA65` |
| Görünen ad | `GeoCam: Audit` |
| Sürüm / Build | `1.0` / `1` |
| Cihaz ailesi | iPhone + iPad (`TARGETED_DEVICE_FAMILY = 1,2`) |

---

## İçindekiler

- [Klasör yapısı](#klasör-yapısı)
- [Özellikler](#özellikler)
- [YAYIN ÖNCESİ: Kritik eksikler](#yayın-öncesi-kritik-eksikler)
- [App Store yayın rehberi (Adım 0 → 21)](#app-store-yayın-rehberi)
- [Sık ret nedenleri](#sık-ret-nedenleri)
- [Son kontrol listesi](#son-kontrol-listesi)
- [Bilinen boşluklar](#bilinen-boşluklar)
- [Yol haritası](#yol-haritası)
- [Geliştirme](#geliştirme)
- [İletişim](#i̇letişim)

---

## Klasör yapısı

```text
GeoCam/
├── App/                 # GeoCamApp, AppBootstrapView, RootView, Splash, DI
├── Core/                # Constants, Extensions, Utilities (L10n)
├── Features/
│   ├── Camera/          # AVFoundation, çekim kuyruğu, cihaz yönü, UI
│   ├── Location/        # GPS, pusula, reverse geocode
│   ├── Photo/           # Overlay, filigran, EXIF, galeri
│   ├── Video/           # Video damga + filigran
│   └── Settings/        # Dil, kamera, marka, iş bilgisi
├── Shared/              # Ortak bileşenler (SideMenu, Draggable overlay)
├── Resources/           # Assets.xcassets
└── Info.plist
```

---

## Özellikler

### Kamera
- AVFoundation oturumu, hızlı açılış
- Fotoğraf / video modu
- Flaş: Auto / On / Off
- Ön / arka kamera
- Zoom (0.5× / 1× / 2× + pinch)
- Çerçeve oranı: **4:3** (çerçeveli önizleme) ve **9:16** (tam ekran)
- Seri çekim kuyruğu (`CaptureProcessingQueue`)
- İsteğe bağlı **orijinali de kaydet** (aynı oran, damgasız)

### Filigran
- Damgalı fotoğraf/videoya **zorunlu** sağ alt filigran
- Satır 1: `GeoCam: Audit`
- Satır 2: orijinallik metni — seçili dile göre
- İlk sürümde kapatılamaz (`AppConstants.Features.allowsRemovingAppWatermark = false`)

### Konum & pusula
- Enlem, boylam, rakım, yatay GPS doğruluğu (metre)
- Manyetik yön: derece + N / NE / E / SE / S / SW / W / NW
- Reverse geocode: mahalle, ilçe, il, ülke (yoksa koordinat)
- İzin kapalı / aranıyor durumları için bilgilendirme UI

### Bilgi katmanı
- Canlı önizleme ≈ kayda basılan çıktı
- Alanlar: tarih, saat, adres, koordinat, rakım, yön, GPS hassasiyeti
- 7 layout: kompakt, kart, şerit, sade, poster, ikili, kapsül
- Ekran döndürme kilidi kapalıyken bile katman cihaz yönüne göre döner
- Sürüklenebilir konum, sağa/sola yaslama, pinch ile tüm tasarımın ölçeği (%45–%100)
- EXIF: kaynak capture metadata JPEG'e aktarılır

### Kurumsal
- Marka: ad, logo, SF Symbol, font, renk
- İş Emri, Site ID, Konu/Not (ayarlar + kamera sheet)

### Uygulama
- Dil: Türkçe, English, Español, Deutsch
- Tema: sistem / açık / koyu
- Splash + App Icon (light / dark / tinted)
- Fotoğraflar'a kayıt + thumbnail kısayolu
- Çekimler ayrıca **GeoCam** adlı albümde toplanır (yoksa ilk kayıtta oluşturulur)

---

## YAYIN ÖNCESİ: Kritik eksikler

Aşağıdaki maddeler **şu an projede eksik veya hatalı**. 1–4 arası maddeler yükleme/inceleme sırasında **ret veya hata** üretir.

| # | Konu | Mevcut durum | Sonuç | Adım |
|---|------|--------------|-------|------|
| 1 | App Icon alfa kanalı | `AppIcon.png` alfa içeriyor (`hasAlpha: yes`) | **ITMS-90717 ile yükleme reddi** | [Adım 7](#adım-7--app-icon-alfa-kanalını-temizle) |
| 2 | Privacy Manifest | `PrivacyInfo.xcprivacy` **yok**, `UserDefaults` kullanılıyor | **ITMS-91053 uyarı/ret** | [Adım 5](#adım-5--privacy-manifest-privacyinfoxcprivacy) |
| 3 | Export compliance | `ITSAppUsesNonExemptEncryption` **yok** | Her build'de manuel soru, gönderim engeli | [Adım 6](#adım-6--export-compliance-şifreleme-beyanı) |
| 4 | İzin metinleri tek dilde | 4 izin metni de **yalnızca Türkçe**, sabit | Guideline 5.1.1 riski | [Adım 4](#adım-4--i̇zin-metinleri-ve-dil-listesi) |
| 5 | iPad desteği | `TARGETED_DEVICE_FAMILY = 1,2` ama iPad için tasarım/test yok | iPad ekran görüntüsü zorunlu + Guideline 2.1 riski | [Adım 3](#adım-3--xcode-hedef-ayarları) |
| 6 | Dil beyanı | `CFBundleLocalizations` yok → App Store "English" gösterir | 4 dil listelenmez | [Adım 4](#adım-4--i̇zin-metinleri-ve-dil-listesi) |
| 7 | Bundle ID biçimi | `metinbiyik.GeoCam` (ters-DNS değil) | Ret sebebi değil, ama düzeltmek için **son şans** | [Adım 2](#adım-2--bundle-id-ve-app-id) |

### Uyarı: “offline” ifadesi

`GeocodingService` adres çözümlemesi için `CLGeocoder` kullanır ve bu **internet gerektirir**. App Store açıklamasında “tamamen çevrimdışı çalışır” yazmayın; bunun yerine:

> Fotoğraf, konum ve damga işlemleri cihazda yapılır. Yalnızca adres (mahalle/ilçe/il) çözümlemesi Apple'ın konum servisini kullanır. Verileriniz bizim sunucumuza gönderilmez.

---

## App Store yayın rehberi

### Adım 0 — Hesap, sözleşme ve vergi

1. [developer.apple.com](https://developer.apple.com) → **Apple Developer Program** üyeliği aktif olmalı (yıllık 99 USD).
2. [App Store Connect](https://appstoreconnect.apple.com) → **Business (İş)** bölümü:
   - **Paid Applications Agreement** — ücretli satacaksanız zorunlu, ücretsizde gerekmez.
   - **Free Applications Agreement** — otomatik kabul, "Active" görünmeli.
3. **Banka bilgisi + Vergi formu (W-8BEN)** — yalnızca ücretli / IAP varsa. GeoCam v1.0 ücretsiz ise atlayın.
4. **Users and Access** → Rolünüz `Account Holder` veya `Admin` olmalı.

**Kontrol:** App Store Connect ana sayfada "Agreements, Tax, and Banking" alanında kırmızı uyarı olmamalı.

---

### Adım 1 — Uygulama adı müsaitlik kontrolü

App Store'da uygulama adı **globalde tekildir**.

| Alan | Değer | Limit |
|------|-------|-------|
| App Name | `GeoCam: Audit` | 30 karakter (13 kullanılıyor) |

Yedek adlar (ilki alınmışsa):
- `GeoCam Audit`
- `GeoCam Field Camera`
- `GeoCam: Saha Kamerası`

App Store Connect'te "New App" ekranında ad alınmışsa hata verir. Adı **rezerve etmek için** boş bir app kaydı oluşturmak yeterlidir (90 gün geçerli).

> "GeoCam" adının marka ihlali oluşturmadığını [tmsearch.uspto.gov](https://tmsearch.uspto.gov) ve TÜRKPATENT üzerinden kontrol edin. Guideline 5.2.1 ihlali reddin en can sıkıcı türüdür.

---

### Adım 2 — Bundle ID ve App ID

Mevcut değer: `metinbiyik.GeoCam`

Bu geçerli çalışır ama ters-DNS standardına uymaz. **App Store'a ilk yüklemeden sonra bundle ID asla değiştirilemez.** Değiştirecekseniz şimdi yapın:

Önerilen: `dev.biyik.geocam`

**Değiştirme:** Xcode → `GeoCam` target → **Signing & Capabilities** → Bundle Identifier alanı. Test target'ları da (`metinbiyik.GeoCamTests`, `metinbiyik.GeoCamUITests`) buna göre güncellenmeli.

**Kaydetme:** Otomatik imzalama (`CODE_SIGN_STYLE = Automatic`) açık olduğu için Xcode App ID'yi kendisi oluşturur. Manuel isterseniz: developer.apple.com → Certificates, Identifiers & Profiles → Identifiers → **+** → App IDs → App → Explicit.

**Capability gerekmez:** GeoCam push notification, iCloud, Sign in with Apple, HealthKit kullanmıyor. Hiçbir capability eklemeyin — gereksiz capability entitlement uyuşmazlığı üretir.

---

### Adım 3 — Xcode hedef ayarları

`GeoCam.xcodeproj` → target `GeoCam` → Build Settings.

| Ayar | Olması gereken | Şu an |
|------|----------------|-------|
| `MARKETING_VERSION` | `1.0` | ✅ `1.0` |
| `CURRENT_PROJECT_VERSION` | `1` | ✅ `1` |
| `IPHONEOS_DEPLOYMENT_TARGET` | `17.0` | ✅ `17.0` |
| `SWIFT_VERSION` | `6.0` | ✅ `6.0` |
| `PRODUCT_BUNDLE_IDENTIFIER` | ters-DNS | ⚠️ `metinbiyik.GeoCam` |
| `INFOPLIST_KEY_CFBundleDisplayName` | `GeoCam: Audit` | ✅ |
| `TARGETED_DEVICE_FAMILY` | Karar verin ↓ | ⚠️ `1,2` |
| `DEVELOPMENT_TEAM` | `4V29PYSA65` | ✅ |
| Build Configuration (Archive) | `Release` | ✅ |

#### iPad kararı (madde 5)

`.cursorrules` "yalnızca iOS/iPhone" diyor ama proje iPad'i de hedefliyor. İki seçenek:

**A) iPhone-only (önerilen, v1.0 için)**

Xcode → Build Settings → `Targeted Device Families` → yalnızca **iPhone**.

```
TARGETED_DEVICE_FAMILY = 1;
```

Sonuç: iPad ekran görüntüsü gerekmez, iPad'de "iPhone uygulaması" olarak çalışır, Guideline 2.1 riski kalkar.

**B) Universal kalsın**

O zaman şunlar zorunlu:
- iPad'de gerçek cihaz testi (bölünmüş görünüm, Stage Manager, klavye)
- 13" iPad ekran görüntüsü (2064 × 2752 px)
- `UIRequiresFullScreen` kararı (kamera uygulamasında genelde `true` mantıklı)

#### Yönelim ayarı

Zaten doğru:
```
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone =
  "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
```

---

### Adım 4 — İzin metinleri ve dil listesi

#### 4.1 Mevcut izin metinleri

Proje `GENERATE_INFOPLIST_FILE = YES` kullandığı için izin metinleri **Build Settings** içinde:

| Anahtar | Neden gerekli | Mevcut metin |
|---------|---------------|--------------|
| `NSCameraUsageDescription` | Fotoğraf/video çekimi | "Fotoğraf çekebilmek için kamera erişimine ihtiyaç duyulur." |
| `NSLocationWhenInUseUsageDescription` | Konum damgası | "Fotoğrafa konum, adres, rakım ve pusula bilgisi eklemek için konum erişimine ihtiyaç duyulur." |
| `NSMicrophoneUsageDescription` | Sesli video | "Videoları sesli kaydedebilmek için mikrofon erişimine ihtiyaç duyulur." |
| `NSPhotoLibraryAddUsageDescription` | Galeriye kayıt | "Çekilen fotoğraf ve videoları kaydedebilmek için Fotoğraflar erişimine ihtiyaç duyulur." |
| `NSPhotoLibraryUsageDescription` | **GeoCam albümü** | "Çekimlerinizi kaydetmek ve GeoCam albümünde toplamak için Fotoğraflar erişimine ihtiyaç duyulur. Mevcut fotoğraflarınız okunmaz." |

> **Neden tam kitaplık erişimi?** Çekimler `GeoCam` adlı özel bir albümde toplanıyor. PhotoKit'te albüm **bulmak** (fetch) okuma yetkisi ister; salt ekleme (`.addOnly`) yetkisiyle mevcut albüm görülemediği için her çekimde yeni bir albüm oluşurdu. Bu yüzden servis `.readWrite` yetkisi istiyor. Uygulama kullanıcının mevcut fotoğraflarını **okumuyor**; yetki yalnızca albümü çözmek için kullanılıyor. İnceleme notlarına (Adım 10) bu cümleyi eklemeniz, Guideline 5.1.1 sorularını baştan kapatır.
>
> Kullanıcı "Seçili Fotoğraflar" (limited) seçerse albüm oluşturulamaz; bu durumda çekim yine kaydedilir, sadece albüme eklenmez. Kod bu duruma karşı sessiz geri düşüş yapar.

Bu metinler **yeterince açıklayıcı** (Guideline 5.1.1 için önemli), ancak **yalnızca Türkçe**. Cihaz dili İngilizce olan bir Apple inceleyicisi Türkçe izin metni görür — bu tek başına ret sebebi olmasa da inceleme sürtünmesi yaratır.

#### 4.2 İzin metinlerini 4 dile çevirin

**Dosya adı:** `GeoCam/Resources/InfoPlist.xcstrings` (String Catalog)

Xcode → File → New → File → **String Catalog** → adı `InfoPlist` → target `GeoCam`.

Sonra Xcode → Project → Info → **Localizations** bölümünden şu dilleri ekleyin: `Turkish (tr)`, `Spanish (es)`, `German (de)`. (`English` zaten `developmentRegion`.)

Girilecek metinler:

| Anahtar | EN | TR | ES | DE |
|---------|----|----|----|----|
| `NSCameraUsageDescription` | GeoCam needs camera access to take the photos and videos you stamp with location data. | Konum bilgisiyle damgalayacağınız fotoğraf ve videoları çekebilmek için kamera erişimi gerekir. | GeoCam necesita la cámara para tomar las fotos y vídeos que sellará con datos de ubicación. | GeoCam benötigt Kamerazugriff, um Fotos und Videos aufzunehmen, die mit Standortdaten versehen werden. |
| `NSLocationWhenInUseUsageDescription` | Your location is used only to stamp coordinates, address, altitude and compass heading onto the photo. It never leaves your device. | Konumunuz yalnızca fotoğrafa koordinat, adres, rakım ve pusula yönü basmak için kullanılır. Cihazınızdan çıkmaz. | Su ubicación se usa solo para estampar coordenadas, dirección, altitud y rumbo en la foto. Nunca sale de su dispositivo. | Ihr Standort wird nur verwendet, um Koordinaten, Adresse, Höhe und Kompassrichtung auf das Foto zu stempeln. Er verlässt Ihr Gerät nicht. |
| `NSMicrophoneUsageDescription` | Microphone access is required to record audio with your videos. | Videolarınızı sesli kaydedebilmek için mikrofon erişimi gerekir. | Se requiere acceso al micrófono para grabar audio con sus vídeos. | Mikrofonzugriff ist erforderlich, um Ton mit Ihren Videos aufzunehmen. |
| `NSPhotoLibraryAddUsageDescription` | GeoCam saves your stamped photos and videos to your photo library. | Damgalanan fotoğraf ve videolarınız Fotoğraflar kitaplığınıza kaydedilir. | GeoCam guarda sus fotos y vídeos sellados en su fototeca. | GeoCam speichert Ihre gestempelten Fotos und Videos in Ihrer Fotomediathek. |
| `NSPhotoLibraryUsageDescription` | Access is used only to save your captures into a "GeoCam" album. Your existing photos are never read. | Erişim yalnızca çekimlerinizi "GeoCam" albümüne kaydetmek için kullanılır. Mevcut fotoğraflarınız okunmaz. | El acceso se usa solo para guardar sus capturas en un álbum "GeoCam". Sus fotos existentes nunca se leen. | Der Zugriff dient nur dazu, Ihre Aufnahmen in einem "GeoCam"-Album zu speichern. Ihre vorhandenen Fotos werden nie gelesen. |

> String Catalog eklediğinizde Build Settings'teki `INFOPLIST_KEY_NS...UsageDescription` satırlarını **silin**, yoksa çeviri ezilir.

#### 4.3 Dil listesini App Store'a bildirin (madde 6)

Uygulama sistem lokalizasyonu yerine kendi `L10n` katmanını kullandığı için App Store dili "English" sanır. Düzeltmek için `GeoCam/Info.plist` dosyasına ekleyin:

```xml
<key>CFBundleLocalizations</key>
<array>
    <string>en</string>
    <string>tr</string>
    <string>es</string>
    <string>de</string>
</array>
```

---

### Adım 5 — Privacy Manifest (`PrivacyInfo.xcprivacy`)

Apple, "required reason API" kullanan tüm uygulamalardan privacy manifest ister. GeoCam `UserDefaults` kullanıyor (`SettingsStore`) → **kategori `CA92.1`** beyanı zorunlu.

**Dosya adı:** `GeoCam/Resources/PrivacyInfo.xcprivacy`

Xcode → File → New → File → **App Privacy File** → target `GeoCam`. Sonra "Open As → Source Code" ile şu içeriği yapıştırın:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>

    <key>NSPrivacyTrackingDomains</key>
    <array/>

    <key>NSPrivacyCollectedDataTypes</key>
    <array/>

    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

Açıklamalar:
- `NSPrivacyTracking = false` — reklam/izleme yok.
- `NSPrivacyCollectedDataTypes = []` — hiçbir veri toplanmıyor (App Privacy formuyla **birebir tutarlı olmalı**).
- `CA92.1` = "Uygulamanın yalnızca kendi erişebildiği kullanıcı tercihlerini saklamak."

> İleride dosya oluşturma/değiştirme tarihi okursanız `NSPrivacyAccessedAPICategoryFileTimestamp` + `C617.1`, disk alanı okursanız `...DiskSpace` + `E174.1` eklemeniz gerekir. Şu an gerekmiyor.

**Doğrulama:** Archive sonrası `GeoCam.app` içinde `PrivacyInfo.xcprivacy` bulunmalı:

```bash
unzip -l build/GeoCam.ipa | grep -i privacyinfo
```

---

### Adım 6 — Export compliance (şifreleme beyanı)

GeoCam özel şifreleme kullanmıyor; yalnızca sistemin HTTPS'i (CLGeocoder) devrede — bu **muaf** kategoridir.

`GeoCam/Info.plist` dosyasına ekleyin:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Bu satır olmazsa her build yüklemesinde App Store Connect "Missing Compliance" bekletir.

`GeoCam/Info.plist` son hali şöyle olmalı:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>UILaunchScreen</key>
    <dict>
        <key>UIColorName</key>
        <string>SplashBackground</string>
    </dict>
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
    <key>CFBundleLocalizations</key>
    <array>
        <string>en</string>
        <string>tr</string>
        <string>es</string>
        <string>de</string>
    </array>
</dict>
</plist>
```

---

### Adım 7 — App Icon: alfa kanalını temizle

**Mevcut sorun:** `AppIcon.png` alfa kanalı içeriyor. App Store Connect bunu şu hatayla reddeder:

```
ITMS-90717: Invalid App Store Icon. The App Store Icon in the asset catalog
in 'GeoCam.app' can't be transparent nor contain an alpha channel.
```

**Kural:**

| Dosya | Alfa | Not |
|-------|------|-----|
| `AppIcon.png` (light) | **Olmamalı** | Tam opak, 1024×1024, sRGB |
| `AppIcon-Dark.png` | Olabilir | Xcode arka planı kendisi ekler |
| `AppIcon-Tinted.png` | Olmalı | Gri tonlamalı, arka plansız |

**Düzeltme komutu:**

```bash
cd GeoCam/Resources/Assets.xcassets/AppIcon.appiconset
sips -s format jpeg -s formatOptions 100 AppIcon.png --out /tmp/icon.jpg
sips -s format png /tmp/icon.jpg --out AppIcon.png
sips -g hasAlpha AppIcon.png   # "hasAlpha: no" görmelisiniz
```

**Ek ikon kuralları:**
- 1024 × 1024 px, PNG, sRGB veya P3
- Yuvarlatılmış köşe **eklemeyin** (sistem kırpar)
- Katman/şeffaflık/gölge yok
- Metin okunabilir olmalı (küçük boyutta test edin)

---

### Adım 8 — Launch screen

Zaten yapılandırılmış: `UILaunchScreen` → `SplashBackground` renk seti. Storyboard gerekmez, iOS 17+ için doğru yöntem.

Kontrol: Uygulama açılışında beyaz/siyah flaş olmamalı, doğrudan lacivert zemin gelmeli.

---

### Adım 9 — Sürüm ve build numaraları

| Alan | Değer | Kural |
|------|-------|-------|
| `MARKETING_VERSION` (Version) | `1.0` | Kullanıcının gördüğü. `1.0` → `1.0.1` → `1.1` |
| `CURRENT_PROJECT_VERSION` (Build) | `1` | **Her yüklemede artmalı.** Aynı build iki kez yüklenemez |

İkinci yükleme yaparsanız build `2` olmalı. Xcode → target → General → Build alanı.

---

### Adım 10 — Yayın öncesi cihaz testi

Simülatörde kamera yok; **gerçek iPhone'da** test edin.

| # | Senaryo | Beklenen |
|---|---------|----------|
| 1 | İlk açılış, tüm izinleri **reddet** | Çökme yok, yönlendirme ekranı görünür |
| 2 | Ayarlar'dan izinleri aç, uygulamaya dön | Kamera + konum çalışır |
| 3 | Uçak modu, fotoğraf çek | Adres yerine koordinat basılır, çökme yok |
| 4 | GPS henüz sabitlenmemişken çek | Boş alan gösterilmez, hata yok |
| 5 | 4:3 ve 9:16 modlarında çekim | Önizleme = çıktı |
| 6 | Telefonu yan çevir (kilit açık/kapalı) | Bilgi katmanı döner, taşma yok |
| 7 | Bilgi katmanını sürükle + pinch | Konum ve punto korunur |
| 8 | 4 dilin her birine geç | Tüm metinler değişir, kesik metin yok |
| 9 | Açık / koyu tema | Kontrast sorunu yok |
| 10 | Video kaydet (mikrofon izni yok) | Sessiz kaydeder, çökmez |
| 11 | Hızlı 10 fotoğraf (kuyruk) | Hepsi kaydedilir, bellek şişmez |
| 12 | Arka plan → ön plan | Kamera oturumu geri gelir |
| 13 | Dinamik Yazı Tipi (en büyük) | Arayüz kullanılabilir |
| 14 | VoiceOver açık | Butonlar etiketli |
| 15 | Marka logosu yükle, çek | Logo damgada görünür |

Ayrıca Xcode → Product → **Analyze** ve Instruments → **Leaks** ile bellek sızıntısı kontrolü.

---

### Adım 11 — Archive ve yükleme

#### 11.1 Archive

Xcode:
1. Şema: **GeoCam**, hedef: **Any iOS Device (arm64)**
2. Product → **Archive**
3. Organizer açılır → **Distribute App** → **App Store Connect** → **Upload**
4. "Manage Version and Build Number" → işaretsiz bırakın (kendiniz kontrol edin)
5. Automatic signing → **Next** → **Upload**

Terminalden (alternatif):

```bash
xcodebuild -project GeoCam.xcodeproj \
  -scheme GeoCam \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/GeoCam.xcarchive \
  archive
```

**Dosya adı:** `ExportOptions.plist` (proje kökünde)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>4V29PYSA65</string>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

```bash
xcodebuild -exportArchive \
  -archivePath build/GeoCam.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist ExportOptions.plist
```

#### 11.2 İşleme

Yükleme sonrası App Store Connect → TestFlight → Builds. Durum sırası:
`Processing` → `Ready to Submit` (5–30 dk).

E-postayla gelen ITMS uyarılarını mutlaka okuyun.

---

### Adım 12 — App Store Connect kaydı oluştur

App Store Connect → **My Apps** → **+** → **New App**

| Alan | Girilecek değer |
|------|-----------------|
| Platforms | ✅ iOS |
| Name | `GeoCam: Audit` |
| Primary Language | `Turkish` (veya `English (U.S.)` — global hedefliyorsanız İngilizce) |
| Bundle ID | Adım 2'de belirlediğiniz |
| SKU | `GEOCAM-AUDIT-001` (dahili, kullanıcı görmez) |
| User Access | `Full Access` |

> **Primary Language kararı:** Birincil dil, çeviri girilmemiş ülkelerde gösterilir. Uygulama global satılacaksa `English (U.S.)` seçin, Türkçe'yi ek lokalizasyon olarak ekleyin.

---

### Adım 13 — Mağaza metinleri (kopyala-yapıştır)

App Store Connect → uygulamanız → sol menü **Distribution / iOS App 1.0** → dil seçici ile 4 dili tek tek doldurun.

Karakter limitleri:

| Alan | Limit | Değiştirilebilir mi? |
|------|-------|----------------------|
| Name | 30 | Yeni sürüm gerektirir |
| Subtitle | 30 | Yeni sürüm gerektirir |
| Promotional Text | 170 | **Her an değişir** (inceleme gerekmez) |
| Description | 4000 | Yeni sürüm gerektirir |
| Keywords | 100 | Yeni sürüm gerektirir |
| What's New | 4000 | Yeni sürüm |

---

#### 🇹🇷 Türkçe

**Subtitle** (27/30)
```
Konum damgalı saha kamerası
```

**Promotional Text** (155/170)
```
Fotoğraflarınıza konum, adres, tarih, rakım ve pusula bilgisini otomatik basın. Saha, denetim ve ekspertiz işleri için tasarlandı. Hesap yok, reklam yok.
```

**Keywords** (93/100)
```
konum damgası,gps kamera,saha,denetim,koordinat,zaman damgası,rapor,inşaat,ekspertiz,filigran
```

**Description**
```
GeoCam: Audit, sahada çekilen her fotoğrafın nerede ve ne zaman çekildiğini kanıtlayan profesyonel bir kamera uygulamasıdır.

Fotoğrafı çektiğiniz anda; GPS koordinatları, açık adres, tarih, saat, rakım, pusula yönü ve GPS doğruluk değeri görüntünün üzerine temiz bir bilgi katmanı olarak basılır. Sağ alt köşedeki filigran, kaydın GeoCam ile alındığını belgeler.

KİMLER İÇİN
• İnşaat ve şantiye ekipleri
• Sigorta eksperleri ve hasar tespiti
• Belediye ve saha denetim personeli
• Teknik servis ve bakım ekipleri
• Emlak, altyapı ve arazi çalışmaları

ÖZELLİKLER
• Otomatik konum, adres, tarih, saat damgası
• Rakım, pusula yönü (derece + N/NE/E/SE/S/SW/W/NW) ve GPS hassasiyeti
• 7 farklı bilgi katmanı tasarımı
• Bilgi katmanını parmağınızla istediğiniz yere taşıyın
• İki parmakla metin boyutunu ayarlayın
• 4:3 ve 9:16 çerçeve oranları
• Fotoğraf ve video kaydı
• Ön/arka kamera, flaş, 0.5× / 1× / 2× zoom
• Şirket logosu, marka adı, renk ve font ekleme
• İş Emri, Site ID ve not alanları
• İsteğe bağlı olarak damgasız orijinali de kaydetme
• Seri çekim kuyruğu — beklemeden çekmeye devam edin
• Türkçe, İngilizce, İspanyolca, Almanca
• Açık ve koyu tema

GİZLİLİK
Fotoğraflarınız yalnızca cihazınızda işlenir ve Fotoğraflar kitaplığınıza kaydedilir. Hiçbir görsel veya konum verisi sunucularımıza gönderilmez. Kullanıcı hesabı, reklam ve analitik izleme yoktur. Yalnızca adres çözümlemesi Apple'ın konum servisini kullanır.

Sorularınız için: metin@biyik.dev
```

---

#### 🇬🇧 English (U.S.)

**Subtitle** (24/30)
```
GPS stamped field camera
```

**Promotional Text** (163/170)
```
Automatically stamp location, address, date, altitude and compass heading onto your photos. Built for field, inspection and survey work. No account, no ads.
```

**Keywords** (93/100)
```
gps camera,timestamp,geotag,field,inspection,construction,survey,watermark,coordinates,report
```

**Description**
```
GeoCam: Audit is a professional camera app that proves where and when every field photo was taken.

The moment you capture, GPS coordinates, full address, date, time, altitude, compass heading and GPS accuracy are printed onto the image as a clean information layer. The watermark in the bottom-right corner documents that the record was made with GeoCam.

WHO IT IS FOR
• Construction and site teams
• Insurance adjusters and damage assessment
• Municipal and field inspection staff
• Technical service and maintenance crews
• Real estate, infrastructure and land surveys

FEATURES
• Automatic location, address, date and time stamp
• Altitude, compass heading (degrees + N/NE/E/SE/S/SW/W/NW) and GPS accuracy
• 7 information layer designs
• Drag the info layer anywhere with your finger
• Pinch to adjust text size
• 4:3 and 9:16 frame ratios
• Photo and video capture
• Front/rear camera, flash, 0.5× / 1× / 2× zoom
• Add company logo, brand name, color and font
• Work order, Site ID and note fields
• Optionally keep the unstamped original as well
• Burst capture queue — keep shooting without waiting
• Turkish, English, Spanish, German
• Light and dark themes

PRIVACY
Your photos are processed only on your device and saved to your photo library. No image or location data is sent to our servers. There is no user account, no advertising and no analytics tracking. Only address lookup uses Apple's location service.

Questions: metin@biyik.dev
```

---

#### 🇪🇸 Español

**Subtitle** (23/30)
```
Cámara de campo con GPS
```

**Promotional Text** (167/170)
```
Estampa automáticamente ubicación, dirección, fecha, altitud y rumbo en tus fotos. Creada para trabajo de campo, inspección y peritaje. Sin cuenta y sin anuncios.
```

**Keywords** (94/100)
```
camara gps,geoetiqueta,marca de tiempo,campo,inspeccion,obra,coordenadas,informe,marca de agua
```

**Description**
```
GeoCam: Audit es una aplicación de cámara profesional que demuestra dónde y cuándo se tomó cada foto de campo.

En el momento de la captura, las coordenadas GPS, la dirección completa, la fecha, la hora, la altitud, el rumbo de la brújula y la precisión del GPS se imprimen sobre la imagen como una capa de información limpia. La marca de agua en la esquina inferior derecha documenta que el registro se realizó con GeoCam.

PARA QUIÉN
• Equipos de construcción y obra
• Peritos de seguros y evaluación de daños
• Personal municipal y de inspección de campo
• Equipos de servicio técnico y mantenimiento
• Inmobiliaria, infraestructura y topografía

FUNCIONES
• Sello automático de ubicación, dirección, fecha y hora
• Altitud, rumbo (grados + N/NE/E/SE/S/SW/W/NW) y precisión GPS
• 7 diseños de capa de información
• Mueve la capa con el dedo a donde quieras
• Pellizca para ajustar el tamaño del texto
• Proporciones 4:3 y 9:16
• Captura de fotos y vídeo
• Cámara frontal/trasera, flash, zoom 0.5× / 1× / 2×
• Añade logotipo, nombre de marca, color y tipografía
• Campos de orden de trabajo, ID de sitio y notas
• Guarda opcionalmente también el original sin sello
• Cola de captura en ráfaga: sigue disparando sin esperar
• Turco, inglés, español, alemán
• Tema claro y oscuro

PRIVACIDAD
Tus fotos se procesan solo en tu dispositivo y se guardan en tu fototeca. No se envía ninguna imagen ni dato de ubicación a nuestros servidores. No hay cuenta de usuario, ni publicidad, ni seguimiento analítico. Solo la búsqueda de direcciones usa el servicio de ubicación de Apple.

Consultas: metin@biyik.dev
```

---

#### 🇩🇪 Deutsch

**Subtitle** (26/30)
```
Feldkamera mit GPS-Stempel
```

**Promotional Text** (168/170)
```
Stempeln Sie Standort, Adresse, Datum, Höhe und Kompassrichtung automatisch auf Ihre Fotos. Für Außendienst, Inspektion und Gutachten. Ohne Konto, ohne Werbung.
```

**Keywords** (94/100)
```
gps kamera,zeitstempel,geotag,baustelle,inspektion,gutachten,koordinaten,bericht,wasserzeichen
```

**Description**
```
GeoCam: Audit ist eine professionelle Kamera-App, die belegt, wo und wann jedes Feldfoto aufgenommen wurde.

Im Moment der Aufnahme werden GPS-Koordinaten, vollständige Adresse, Datum, Uhrzeit, Höhe, Kompassrichtung und GPS-Genauigkeit als saubere Informationsebene auf das Bild gedruckt. Das Wasserzeichen unten rechts dokumentiert, dass die Aufnahme mit GeoCam erstellt wurde.

FÜR WEN
• Bau- und Baustellenteams
• Versicherungsgutachter und Schadensbewertung
• Kommunales und Außendienst-Prüfpersonal
• Technischer Service und Wartungsteams
• Immobilien, Infrastruktur und Vermessung

FUNKTIONEN
• Automatischer Standort-, Adress-, Datums- und Zeitstempel
• Höhe, Kompassrichtung (Grad + N/NE/E/SE/S/SW/W/NW) und GPS-Genauigkeit
• 7 Designs für die Informationsebene
• Informationsebene mit dem Finger frei positionieren
• Textgröße per Pinch-Geste anpassen
• Seitenverhältnisse 4:3 und 9:16
• Foto- und Videoaufnahme
• Front-/Rückkamera, Blitz, 0,5× / 1× / 2× Zoom
• Firmenlogo, Markenname, Farbe und Schrift hinzufügen
• Felder für Auftrag, Standort-ID und Notiz
• Optional das ungestempelte Original zusätzlich speichern
• Serienaufnahme-Warteschlange – ohne Wartezeit weiterfotografieren
• Türkisch, Englisch, Spanisch, Deutsch
• Helles und dunkles Design

DATENSCHUTZ
Ihre Fotos werden ausschließlich auf Ihrem Gerät verarbeitet und in Ihrer Fotomediathek gespeichert. Es werden keine Bild- oder Standortdaten an unsere Server gesendet. Es gibt kein Benutzerkonto, keine Werbung und kein Analyse-Tracking. Nur die Adressauflösung nutzt den Standortdienst von Apple.

Fragen: metin@biyik.dev
```

---

#### What's New (1.0 için)

İlk sürümde bu alan **görünmez**. 1.0.1'den itibaren zorunlu.

---

### Adım 14 — Ekran görüntüleri

#### Zorunlu boyutlar (2026)

| Sınıf | Piksel (portre) | Zorunlu mu |
|-------|-----------------|------------|
| iPhone 6.9" | **1320 × 2868** | ✅ Zorunlu |
| iPad 13" | **2064 × 2752** | Yalnızca iPad desteği açıksa |

Diğer tüm boyutları Apple bunlardan otomatik türetir.

**Kurallar:**
- Format: PNG veya JPEG
- Renk: RGB, **alfa kanalı yok**
- Adet: dil başına 1–10 (önerilen: 5–6)
- Boyut: dosya başına < 5 MB

#### Hangi cihazda çekilir

`iPhone 16 Pro Max` / `iPhone 17 Pro Max` / `iPhone Air` → 1320 × 2868 üretir.
Simülatörde: `Cmd + S` ile Masaüstü'ne kaydeder. Ancak **simülatörde kamera yok** → gerçek cihazda çekip mockup'a yerleştirin veya kamera görüntüsünü tasarımda kompoze edin.

#### Önerilen 6 ekran ve altyazıları

| # | Ekran | TR altyazı | EN altyazı |
|---|-------|-----------|-----------|
| 1 | Kamera + bilgi katmanı görünür | Her fotoğrafta konum, tarih ve saat | Location, date and time on every photo |
| 2 | Damgalanmış örnek fotoğraf (şantiye) | Sahadaki kaydınızı kanıtlayın | Prove your field record |
| 3 | 7 layout seçimi ekranı | 7 farklı bilgi tasarımı | 7 information layouts |
| 4 | Marka/logo ayarları | Şirket logonuzu ekleyin | Add your company logo |
| 5 | İş emri sheet'i | İş emri ve site bilgisi | Work order and site ID |
| 6 | Dil + tema ayarları | 4 dil, açık ve koyu tema | 4 languages, light and dark |

**Dosya adlandırma önerisi** (yükleme sırasını korumak için):

```
screenshots/
├── tr/
│   ├── 01-camera-6.9.png
│   ├── 02-stamped-6.9.png
│   ├── 03-layouts-6.9.png
│   ├── 04-branding-6.9.png
│   ├── 05-joborder-6.9.png
│   └── 06-settings-6.9.png
├── en/ ...
├── es/ ...
└── de/ ...
```

> Ekran görüntüsünde gerçek kişisel adres/koordinat göstermeyin. Örnek bir şantiye konumu kullanın.

#### App Preview (video) — opsiyonel

- Süre: 15–30 sn
- 6.9" için: 886 × 1920 px
- Yalnızca uygulama içi görüntü olmalı, dış çekim/eller yasak

---

### Adım 15 — Kategori ve yaş sınırı

#### Kategori

App Store Connect → App Information

| Alan | Değer |
|------|-------|
| Primary Category | **Photo & Video** |
| Secondary Category | **Utilities** |

> Alternatif: kurumsal satış hedefliyorsanız Primary `Business`, Secondary `Photo & Video`. Ancak keşfedilebilirlik Photo & Video'da daha yüksektir.

#### Yaş sınırı (Age Rating)

App Information → Age Rating → **Edit**. GeoCam için tüm cevaplar:

| Soru | Cevap |
|------|-------|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Prolonged Graphic or Sadistic Realistic Violence | None |
| Profanity or Crude Humor | None |
| Mature/Suggestive Themes | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Alcohol, Tobacco, or Drug Use or References | None |
| Simulated Gambling | None |
| Sexual Content or Nudity | None |
| Graphic Sexual Content and Nudity | None |
| Contests | None |
| Unrestricted Web Access | **No** |
| Gambling and Contests | **No** |
| Age Assurance | Uygulanmaz |
| In-app controls / parental gate | Uygulanmaz |
| Capabilities: User-generated content | **No** (içerik paylaşımı/akışı yok) |
| Capabilities: Messaging / chat | **No** |
| Capabilities: Ads | **No** |

**Sonuç: 4+**

#### İçerik hakları (Content Rights)

App Information → Content Rights Information:
- "Does your app contain, show, or access third-party content?" → **No**

---

### Adım 16 — App Privacy (gizlilik etiketi)

App Store Connect → **App Privacy** → Get Started

Bu bölüm `PrivacyInfo.xcprivacy` ile **tutarlı olmak zorundadır**.

#### Ana soru

> "Do you or your third-party partners collect data from this app?"

**Cevap: No, we do not collect data from this app**

**Gerekçe:** Konum, fotoğraf ve ayarlar cihazda kalır; hiçbiri geliştiriciye veya üçüncü tarafa iletilmez. Apple'ın tanımına göre "collect" = veriyi cihazdan çıkarıp geliştiriciye/üçüncü tarafa göndermek. GeoCam bunu yapmaz. Fotoğraflar kitaplığına tam erişim istenmesi de beyanı değiştirmez; erişim yalnızca cihaz üzerinde albüm oluşturmak/bulmak için kullanılır.

> `CLGeocoder` çağrısı Apple'ın kendi servisidir ve Apple'ın kendi gizlilik politikasına tabidir — geliştirici veri toplaması sayılmaz.

Bu cevabı verdiğinizde Apple bir onay ekranı gösterir; **Publish** deyin. Mağazada "Data Not Collected" rozeti çıkar.

⚠️ İleride analytics/crash SDK eklerseniz bu bölümü **mutlaka** güncelleyin. Yanlış beyan, uygulamanın mağazadan kaldırılma sebebidir.

---

### Adım 17 — Gizlilik politikası URL'i

**Zorunlu.** Boş bırakılırsa gönderim yapılamaz.

| Alan | Değer |
|------|-------|
| Privacy Policy URL | `https://biyik.dev/geocam/privacy` |
| Support URL | `https://biyik.dev/geocam/destek` |
| Marketing URL (opsiyonel) | `https://biyik.dev/geocam` |

Bu üç sayfa **yayında ve erişilebilir** olmalı. Apple inceleme sırasında açar; 404 dönerse ret gelir.

**Dosya adı:** `privacy.html` (veya `/geocam/privacy/index.html`)

Kullanabileceğiniz metin:

```markdown
# GeoCam: Audit — Gizlilik Politikası

Son güncelleme: 1 Ağustos 2026

## Özet
GeoCam: Audit hiçbir kişisel veri toplamaz, saklamaz veya üçüncü taraflarla paylaşmaz.
Uygulamanın kullanıcı hesabı, sunucusu, reklam ağı ve analitik izleyicisi yoktur.

## Erişilen veriler ve kullanım amaçları

**Kamera**
Fotoğraf ve video çekmek için kullanılır. Görüntüler yalnızca cihazınızda işlenir.

**Konum (Kullanım sırasında)**
Enlem, boylam, rakım, GPS doğruluğu ve pusula yönü, çekilen görüntünün üzerine
bilgi katmanı olarak basmak amacıyla kullanılır. Konum verisi cihazınızdan
çıkmaz; tarafımıza iletilmez ve saklanmaz.

**Adres çözümleme**
Koordinatı okunabilir bir adrese çevirmek için Apple'ın CLGeocoder servisi
kullanılır. Bu işlem Apple tarafından yürütülür ve Apple'ın gizlilik
politikasına tabidir. Bu istekte kişisel kimlik bilgisi gönderilmez.

**Mikrofon**
Yalnızca video kaydı sırasında ses almak için kullanılır.

**Fotoğraflar**
Çekilen görüntüleri cihazınızın Fotoğraflar kitaplığına kaydetmek ve "GeoCam"
adlı albümde toplamak için kullanılır. Albümün var olup olmadığını anlamak
PhotoKit'te okuma yetkisi gerektirdiği için tam erişim istenir; uygulama
bunun dışında mevcut fotoğraflarınızı okumaz, görüntülemez ve hiçbir yere
göndermez.

**Ayarlar ve marka bilgileri**
Dil, tema, layout tercihi, şirket adı, logo ve iş bilgisi cihazınızda yerel
olarak saklanır (UserDefaults ve uygulama dizini). Sunucuya gönderilmez.

## Veri paylaşımı
Hiçbir veri satılmaz, kiralanmaz veya üçüncü taraflarla paylaşılmaz.

## Çocukların gizliliği
Uygulama çocuklara yönelik değildir ve çocuklardan bilinçli olarak veri toplamaz.

## Veri silme
Uygulamayı silmeniz tüm yerel ayarları ve yüklediğiniz logoyu kaldırır.
Fotoğraflar kitaplığınıza kaydedilmiş görüntüler sizde kalır.

## Değişiklikler
Bu politika güncellenirse bu sayfadaki tarih değiştirilir.

## İletişim
metin@biyik.dev
BIYIK.DEV — https://biyik.dev
```

İngilizce sürümünü de aynı sayfada veya `/privacy/en` altında yayınlayın.

---

### Adım 18 — Fiyatlandırma ve erişilebilirlik

App Store Connect → **Pricing and Availability**

| Alan | Öneri |
|------|-------|
| Price | `Free` (v1.0) |
| Availability | All countries and regions |
| Pre-Orders | Kapalı |
| Distribution on Apple Vision Pro | Kapalı |
| Make available on Mac (Designed for iPad) | Kapalı (kamera uygulaması Mac'te anlamsız) |
| App Store Promotions | Boş |

> Ücretli yapacaksanız Adım 0'daki **Paid Applications Agreement** ve vergi formları tamamlanmış olmalı.

---

### Adım 19 — App Review bilgileri

Sürüm sayfası → **App Review Information**

| Alan | Değer |
|------|-------|
| Sign-in required | ☐ **İşaretsiz** (hesap yok) |
| First Name | Metin Faruk |
| Last Name | Bıyık |
| Phone Number | (uluslararası formatta, ör. +90 5xx xxx xx xx) |
| Email | metin@biyik.dev |

**Notes** alanına yapıştırın:

```
GeoCam: Audit is an offline camera app for field documentation. No account or
login is required — all features are available immediately after granting
permissions.

TESTING NOTE
The app requires a physical device. The camera preview will be black in the
Simulator because no capture device is available.

PERMISSIONS AND WHY THEY ARE NEEDED
- Camera: to capture the photo/video that gets stamped.
- Location (When In Use): the core feature. Coordinates, address, altitude,
  GPS accuracy and compass heading are burned into the image. Location is used
  only for this overlay and is never transmitted off the device.
- Microphone: to record audio in video mode. Denying it still allows silent
  video recording.
- Photo Library: to save the stamped result and to collect every capture in a
  dedicated "GeoCam" album. Full access is requested because PhotoKit requires
  read permission to *look up* an existing album — with add-only access the app
  cannot see the album it created and would produce a duplicate on every shot.
  The app never reads, displays or uploads the user's existing photos; the only
  fetch performed is the one that resolves the "GeoCam" album by title. If the
  user chooses "Selected Photos", captures are still saved — only the album
  grouping is skipped.

PRIVACY
No analytics, no advertising, no third-party SDKs, no user accounts, no server
backend. Reverse geocoding uses Apple's CLGeocoder only.

HOW TO TEST THE MAIN FLOW
1. Launch, grant Camera + Location + Photos permissions.
2. Point at any subject; the info overlay appears over the preview.
3. Drag the overlay to reposition, pinch it to scale the whole design.
4. Tap the shutter. The stamped photo is saved to Photos and to the "GeoCam"
   album automatically.
5. Open the side menu (top-left) to change language, layout, brand and theme.

Contact: metin@biyik.dev
```

**Attachment:** Gerekmez. (Özel donanım/hesap yok.)

---

### Adım 20 — TestFlight (önerilen ara adım)

Doğrudan yayına göndermeden önce:

1. TestFlight → Builds → build seçin
2. **Test Information** doldurun (Beta App Description + Feedback Email)
3. **Internal Testing**: kendi Apple ID'niz + ekip (inceleme gerekmez, anında)
4. **External Testing** (isteğe bağlı, 10.000 kişiye kadar): Beta App Review gerekir, 1–2 gün

Internal TestFlight ile en az **3 farklı iPhone modelinde** Adım 10 listesini tekrarlayın.

---

### Adım 21 — Gönderim

1. Sürüm sayfası → **Build** bölümünde `+` → işlenmiş build'i seçin
2. **Version Release** seçin:
   - `Manually release this version` ← **önerilen** (onay sonrası siz yayınlarsınız)
   - `Automatically release this version`
   - `Automatically release after App Review, no earlier than [tarih]`
3. **Phased Release for Automatic Updates**: 1.0'da anlamsız, sonraki sürümlerde açın
4. Sağ üst → **Add for Review** → **Submit to App Review**

**Durum akışı:**
`Waiting for Review` → `In Review` → `Pending Developer Release` / `Ready for Sale`

Tipik süre: 24–48 saat.

**Ret gelirse:** Resolution Center'dan mesajı okuyun, düzeltip **yeni build** (build no +1) yükleyin ve yanıt yazın. Guideline yorumuna katılmıyorsanız aynı ekrandan itiraz (appeal) edebilirsiniz.

---

## Sık ret nedenleri

Kamera + konum uygulamaları için en sık görülenler:

| Guideline | Sorun | GeoCam'de önlem |
|-----------|-------|-----------------|
| **2.1** Performance – App Completeness | Çökme, boş ekran, çalışmayan özellik | Adım 10 test listesi |
| **2.1** | İzin reddedildiğinde uygulamanın kilitlenmesi | İzin reddi senaryoları test edildi |
| **2.3.3** Accurate Metadata | Ekran görüntüsü uygulamayı yansıtmıyor | Gerçek ekranlardan çekin, mockup'ı abartmayın |
| **2.3.7** | Keywords'te rakip marka adı | Marka adı kullanmayın |
| **4.2** Minimum Functionality | "Sadece bir kamera" algısı | Açıklamada damga/marka/iş emri değerini vurgulayın |
| **5.1.1** Data Collection and Storage | Yetersiz izin metni | Adım 4'teki uzun, amaç belirten metinler |
| **5.1.1(v)** | Konum izni gerekçesi zayıf | Notes'ta ve izin metninde çekirdek işlev olduğu açıklandı |
| **5.1.2** Data Use and Sharing | App Privacy formu ile gerçek davranışın uyuşmaması | "Data Not Collected" + boş `NSPrivacyCollectedDataTypes` |
| **5.2.1** Intellectual Property | Ad/marka çakışması | Adım 1 marka kontrolü |
| **1.5** Developer Information | Support URL çalışmıyor | Adım 17'de sayfaları yayına alın |

---

## Son kontrol listesi

Göndermeden önce hepsini işaretleyin.

### Kod / proje
- [ ] `AppIcon.png` alfa kanalı temizlendi (`sips -g hasAlpha` → `no`)
- [ ] `GeoCam/Resources/PrivacyInfo.xcprivacy` eklendi ve bundle'a giriyor
- [ ] `ITSAppUsesNonExemptEncryption = false` `Info.plist`'te
- [ ] `CFBundleLocalizations` 4 dili içeriyor
- [ ] İzin metinleri 4 dile çevrildi (`InfoPlist.xcstrings`)
- [ ] `TARGETED_DEVICE_FAMILY` kararı verildi (iPhone-only veya iPad testli)
- [ ] Bundle ID nihai (bir daha değişmeyecek)
- [ ] Version `1.0`, Build `1`
- [ ] Release konfigürasyonunda derleme uyarısız
- [ ] Instruments ile bellek sızıntısı yok
- [ ] Tüm SwiftUI Preview'lar çalışıyor
- [ ] `print` / debug log kalıntısı yok

### Test
- [ ] Adım 10'daki 15 senaryo gerçek cihazda geçti
- [ ] En az 3 farklı iPhone modelinde denendi
- [ ] Uçak modunda çökme yok
- [ ] Tüm izinler reddedildiğinde çökme yok

### App Store Connect
- [ ] Uygulama kaydı oluşturuldu, ad rezerve edildi
- [ ] 4 dilde: Name, Subtitle, Promotional Text, Description, Keywords
- [ ] 6.9" ekran görüntüleri (1320 × 2868) — 4 dil için de
- [ ] iPad 13" görüntüleri (yalnızca universal ise)
- [ ] Kategori: Photo & Video + Utilities
- [ ] Age Rating tamamlandı → 4+
- [ ] Content Rights: No
- [ ] App Privacy: "Data Not Collected" → **Published**
- [ ] Privacy Policy URL canlı ve açılıyor
- [ ] Support URL canlı ve açılıyor
- [ ] Pricing: Free, tüm ülkeler
- [ ] App Review Information + Notes dolduruldu
- [ ] Build seçildi ve `Ready to Submit`
- [ ] Version Release: Manually

---

## Bilinen boşluklar

`.cursorrules` ve ürün hedefiyle karşılaştırma:

| Madde | Durum |
|--------|--------|
| HEIF **ve** JPEG | Kayıt şu an **yalnızca JPEG** |
| GPS Speed / Timestamp overlay | Modelde var; katmanda yok |
| EXIF'e uygulama GPS'i yazma | Kaynak EXIF korunur; CL verisi yeniden enjekte edilmez |
| Damgada gerçek glass | Damga yarı saydam siyah; canlıda material var |
| Dynamic Type | Overlay sabit punto (`OverlayTextSize`) |
| Birim testleri | `GeoCamTests` iskelet halinde |
| Ayrı `Compass/` klasörü | Pusula `Location` altında (işlevsel tamam) |
| Sistem lokalizasyonu | Özel `L10n`; `.xcstrings` yalnızca Info.plist için önerildi |

---

## Yol haritası

### v1.0'da var
Logo/marka, video + damga, zorunlu filigran, 4 dil, iş bilgisi, 4:3 / 9:16, cihaz yönüne göre dönen katman

### Henüz yok
| Modül | Not |
|--------|-----|
| QR / barkod | İş emri veya site okutma |
| PDF rapor | Saha özeti |
| Filigranı kaldırma | Pro kapısı hazır, UI yok |
| Bulut / şirket hesabı | Offline kuralı gereği bilinçli yok |
| Firebase / OCR / AI | Planlı değil |
| Mini harita | Damga eki |

### Pro adayları (öncelik sırası)
1. Filigranı kaldırma (ücretli)
2. PDF saha raporu
3. İş geçmişi (son iş emri / site)
4. QR ile iş emri / site
5. Zorunlu alan politikası
6. Çoklu marka profili
7. CSV / JSON indeks
8. HEIF çıktı seçeneği
9. EXIF/IPTC'ye iş emri yazma
10. Albüm adı kuralı (`SiteID_İşEmri_Tarih`)

### Paketleme önerisi
- **Free:** Damga, zorunlu filigran, 1 marka, iş bilgisi, dil, video, 4:3 & 9:16
- **Pro:** Filigransız çıktı, PDF, geçmiş, QR, HEIF, CSV, çoklu marka
- **Pro Ekip:** Şablon kilidi, çoklu kullanıcı, isteğe bağlı sync

> IAP eklerseniz: Adım 0'daki Paid Applications Agreement, `StoreKit 2`, restore purchases butonu (Guideline 3.1.1 zorunlu) ve App Privacy güncellemesi gerekir.

---

## Geliştirme

```bash
open GeoCam.xcodeproj
# Xcode 16+ (proje Xcode 26.6 ile oluşturuldu), iOS 17+ cihaz
```

Derleme kontrolü:

```bash
xcodebuild -scheme GeoCam \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

Gerekli izinler: Kamera, Konum (When In Use), Fotoğraflar (Add), Mikrofon (video).

---

## İletişim

Geliştirici: [Metin Faruk Bıyık — BIYIK.DEV](https://biyik.dev)
Destek: metin@biyik.dev
