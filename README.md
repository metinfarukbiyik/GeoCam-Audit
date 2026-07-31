# GeoCam: Audit

iOS için profesyonel saha / denetim kamerası. Çekilen fotoğraf ve videoya konum, adres, pusula, iş emri ve marka bilgilerini damgalar. Tamamen cihaz içi çalışır; analitik ve reklam yoktur.

| | |
|---|---|
| Platform | iOS 17+ |
| Dil | Swift 6 |
| UI | SwiftUI |
| Mimari | MVVM + protocol servisler |
| Durum | Observation (`@Observable`) |
| Asenkron | async/await, actor kuyruk |

---

## Klasör yapısı

```text
GeoCam/
├── App/                 # GeoCamApp, RootView, Splash, DI
├── Core/                # Constants, Extensions, Utilities
├── Features/
│   ├── Camera/          # AVFoundation, çekim kuyruğu, UI
│   ├── Location/        # GPS, pusula, reverse geocode
│   ├── Photo/           # Overlay, EXIF, galeri kaydı
│   ├── Video/           # Video damga
│   └── Settings/        # Tercihler, marka, iş bilgisi
├── Shared/              # Ortak bileşenler
└── Resources/           # Assets, Info.plist
```

---

## Neler var (mevcut özellikler)

### Kamera
- AVFoundation oturumu, hızlı açılış
- Fotoğraf / video modu
- Flaş: Auto / On / Off
- Ön / arka kamera
- Zoom (0.5 / 1× / 2 + pinch)
- Çerçeve oranı: **4:3** ve **9:16** (canlı önizleme + kayıt kırpma)
- Seri çekim kuyruğu (`CaptureProcessingQueue`) — deklanşör sensör sonrası açılır
- İsteğe bağlı **orijinali de kaydet** (aynı oranda, damgasız)

### Konum & pusula
- Latitude, longitude, rakım, yatay doğruluk (metre)
- Hız ve GPS timestamp modelde tutulur (overlay’de gösterilmez — bkz. eksikler)
- Manyetik yön: derece + N / NE / E / SE / S / SW / W / NW
- Reverse geocode: mahalle, ilçe, il, ülke (yoksa koordinat yedeği)
- İzin yoksa / aranıyorsa bilgilendirme UI

### Bilgi katmanı (overlay)
- Canlı önizleme + foto/video damgası (WYSIWYG’e yakın)
- Alan seçimi: tarih, saat, adres, koordinat, rakım, yön, GPS hassasiyeti
- Birden fazla layout (kompakt, kart, şerit, sade, poster, ikili, kapsül)
- Sürüklenebilir konum, pinch ile metin boyutu
- Glass / material (canlı); damgada yarı saydam koyu arka plan
- EXIF: orijinal capture metadata’sı JPEG çıktısına aktarılır

### Kurumsal / marka
- Marka adı, logo, SF Symbol ikon, font ve renk
- İş Emri, Site ID, Konu/Not (ayarlar + kamera hızlı sheet)
- Geliştirici kredisi (biyik.dev)

### Diğer
- Splash + App Icon
- Tema: sistem / açık / koyu
- Offline; Analytics / reklam / Firebase yok
- Fotoğraflar uygulamasına kayıt + thumbnail kısayolu

---

## `.cursorrules` ile karşılaştırma — eksikler / kısmi

### Çekirdek kurallara göre boşluklar

| Madde | Durum |
|--------|--------|
| HEIF **ve** JPEG desteği | Capture HEVC tercih edebilir; **kayıt her zaman JPEG**. Kullanıcıya HEIF seçeneği yok. |
| GPS **Speed** overlay’de | Modelde var, katmanda gösterilmiyor. |
| GPS **Timestamp** overlay’de | Ayrı alan yok (çekim tarihi/saati var). |
| EXIF’e uygulama GPS’inin yazılması | Kaynak EXIF korunuyor; CoreLocation verisi GPS etiketlerine yeniden enjekte edilmiyor. |
| Damgada gerçek glass material | ImageRenderer sınırından damga yarı saydam siyah; canlıda material var. |
| Dynamic Type | Overlay sabit punto (`OverlayTextSize`); sistem Dynamic Type yok. |
| SwiftUI Preview “her View” | Çoğunda var; bazı layout / düşük seviye View’larda eksik. |
| Birim testleri | `GeoCamTests` iskelet; anlamlı coverage yok. |
| Klasör: ayrı `Compass/` | Pusula `Location` özelliği altında (işlevsel olarak tamam). |

### Karşılanan başlıklar (özet)
Flash Auto/On/Off, ön/arka kamera, pusula yönleri, adres formatı, izin yönetimi, offline / no ads / no analytics, video çekimi + damga, MVVM / SwiftUI / iOS 17 / Swift 6.

### `.cursorrules` “gelecek sürümler” listesi

| Modül | Durum |
|--------|--------|
| Logo ekleme | **Var** (marka / branding) |
| Video çekimi | **Var** |
| QR Kod | Yok |
| Filigran (ayrı watermark) | Yok (marka/logo kısmen karşılar) |
| PDF Rapor | Yok |
| Bulut senkronizasyonu | Yok |
| Şirket hesapları | Yok |
| Firebase | Yok (bilinçli; offline kuralı) |
| OCR | Yok |
| Yapay zeka analizi | Yok |
| Mini harita | Yok |

---

## Pro sürüme eklenebilecekler (not)

Ücretsiz sürümde damga ve temel iş akışı kalsın; Pro’da **rapor, hız, kontrol ve ekip** satsın.

### Öncelikli Pro adayları
1. **PDF saha raporu** — gün / iş emri / site bazlı kapak + foto ızgarası + meta tablo  
2. **İş geçmişi** — son N iş emri / site tek dokunuşla geri yükleme  
3. **QR / barkod** ile iş emri veya site okutma  
4. **Zorunlu alan politikası** — iş emri boşken çekimi engelle / uyar (yönetici PIN)  
5. **Çoklu marka profili** — proje başına logo / renk seti  
6. **CSV / JSON indeks** — foto + koordinat + İE + site eşlemesi (ERP / Excel)  
7. **HEIF çıktı seçeneği** + kalite / seri çekim preset’leri  
8. **EXIF/IPTC UserComment** — iş emri + notu metadata’ya yazma  
9. **Albüm adı kuralı** — `SiteID_İşEmri_Tarih`  
10. **Gelişmiş watermark / filigran** — tekrarlayan desen, opaklık, konum kilitleri  

### Ekip / kurumsal Pro+
- Çoklu kullanıcı / şirket hesabı  
- Merkezi şablon ve marka kilidi  
- İsteğe bağlı bulut yedek / paylaşım (ayrı gizlilik onayı)  
- Yönetici paneli (basit): zorunlu alanlar, layout kilidi  
- MDM / faturalı kurumsal lisans  

### İleri (sonraki dalga)
- Mini harita damgası  
- OCR (tabela / iş emri görselinden metin)  
- AI hasar / etiket önerisi  
- Zaman + konum doğrulama özeti (rapor eki)  

### Önerilen paketleme
- **Free:** Temel damga, 1 marka, iş emri/site/not, 4:3 & 9:16, video  
- **Pro (bireysel):** PDF, geçmiş, QR, HEIF, zorunlu alanlar, CSV, çoklu marka  
- **Pro Ekip:** kullanıcı başı / cihaz paketi + şablon kilidi + (opsiyonel) sync  

---

## Geliştirme

```bash
open GeoCam.xcodeproj
# Xcode 16+, iOS 17+ simülatör veya cihaz
```

Gerekli izinler (`Info.plist` / build settings):
- Kamera  
- Konum (When In Use)  
- Fotoğraflar (Add)  
- Mikrofon (video)

---

## Lisans / iletişim

Geliştirici: [Metin Faruk Bıyık](https://biyik.dev)  
Destek: metin@biyik.dev
