# GeoCam: Audit

Profesyonel saha / denetim kamerası. Çekilen fotoğraf ve videoya konum, adres, pusula, iş bilgisi ve markayı damgalar; sağ altta zorunlu GeoCam filigranı ile kaydın orijinalliğini vurgular.

Tamamen cihaz içi çalışır. Analitik, reklam ve bulut senkronizasyonu yoktur.

| | |
|---|---|
| Platform | iOS 17+ |
| Dil | Swift 6 |
| UI | SwiftUI |
| Mimari | MVVM + protocol servisler |
| Durum | Observation (`@Observable`) |
| Asenkron | async/await, actor kuyruk |
| Yerelleştirme | tr / en / es / de (`L10n`, anında geçiş) |

---

## Klasör yapısı

```text
GeoCam/
├── App/                 # GeoCamApp, RootView, Splash, DI
├── Core/                # Constants, Extensions, Utilities (L10n)
├── Features/
│   ├── Camera/          # AVFoundation, çekim kuyruğu, UI
│   ├── Location/        # GPS, pusula, reverse geocode
│   ├── Photo/           # Overlay, filigran, EXIF, galeri
│   ├── Video/           # Video damga + filigran
│   └── Settings/        # Dil, kamera, marka, iş bilgisi
├── Shared/              # Ortak bileşenler
└── Resources/           # Assets, Info.plist
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
- Satır 2: orijinallik metni (ör. “Orijinal saha kaydı”) — dile göre
- Ücretsiz sürümde kapatılamaz (`AppConstants.Features.allowsRemovingAppWatermark = false`)
- İleride ücretli planda kaldırılabilir hale getirilebilir

### Konum & pusula
- Enlem, boylam, rakım, yatay GPS doğruluğu (metre)
- Manyetik yön: derece + N / NE / E / SE / S / SW / W / NW
- Reverse geocode: mahalle, ilçe, il, ülke (yoksa koordinat)
- İzin kapalı / aranıyor durumları için bilgilendirme UI
- Hız ve GPS timestamp modelde tutulur (katmanda gösterilmez)

### Bilgi katmanı
- Canlı önizleme ≈ kayda basılan çıktı
- Alanlar: tarih, saat, adres, koordinat, rakım, yön, GPS hassasiyeti
- 7 layout: kompakt, kart, şerit, sade, poster, ikili, kapsül
- Sürüklenebilir konum, pinch ile metin boyutu
- Canlıda glass / material; damgada yarı saydam koyu arka plan
- EXIF: kaynak capture metadata JPEG’e aktarılır

### Kurumsal
- Marka: ad, logo, SF Symbol, font, renk
- İş Emri, Site ID, Konu/Not (ayarlar + kamera sheet)
- Geliştirici kredisi ([biyik.dev](https://biyik.dev))

### Uygulama
- Dil: Türkçe, English, Español, Deutsch
- Tema: sistem / açık / koyu
- Splash + App Icon
- Fotoğraflar’a kayıt + thumbnail kısayolu
- Offline; Analytics / reklam / Firebase yok

---

## Bilinen boşluklar

`.cursorrules` ve ürün hedefiyle karşılaştırma:

| Madde | Durum |
|--------|--------|
| HEIF **ve** JPEG | Kayıt şu an **yalnızca JPEG** |
| GPS Speed / Timestamp overlay | Modelde var; katmanda yok |
| EXIF’e uygulama GPS yazma | Kaynak EXIF korunur; CL yeniden enjekte edilmez |
| Damgada gerçek glass | Damga yarı saydam siyah; canlıda material var |
| Dynamic Type | Overlay sabit punto (`OverlayTextSize`) |
| Birim testleri | `GeoCamTests` iskelet |
| Ayrı `Compass/` klasörü | Pusula `Location` altında (işlevsel tamam) |

---

## Yol haritası

### Ücretsiz sürümde var
Logo/marka, video + damga, zorunlu filigran, çoklu dil, iş bilgisi, 4:3 / 9:16

### Henüz yok
| Modül | Not |
|--------|-----|
| QR / barkod | İş emri veya site okutma |
| PDF rapor | Saha özeti |
| Filigranı kaldırma | Pro kapısı hazır, UI yok |
| Bulut / şirket hesabı | Offline kuralı gereği bilinçli yok |
| Firebase / OCR / AI | Planlı değil veya sonraki dalga |
| Mini harita | Damga eki |

### Pro adayları (öncelik)
1. Filigranı kaldırma (ücretli)
2. PDF saha raporu
3. İş geçmişi (son İE / site)
4. QR ile iş emri / site
5. Zorunlu alan politikası
6. Çoklu marka profili
7. CSV / JSON indeks
8. HEIF çıktı seçeneği
9. EXIF/IPTC’ye iş emri yazma
10. Albüm adı kuralı (`SiteID_İşEmri_Tarih`)

### Paketleme önerisi
- **Free:** Damga, zorunlu filigran, 1 marka, iş bilgisi, dil, video, 4:3 & 9:16  
- **Pro:** Filigransız çıktı, PDF, geçmiş, QR, HEIF, CSV, çoklu marka  
- **Pro Ekip:** Şablon kilidi, çoklu kullanıcı, isteğe bağlı sync  

---

## Geliştirme

```bash
open GeoCam.xcodeproj
# Xcode 16+, iOS 17+ simülatör veya cihaz
```

Gerekli izinler:
- Kamera
- Konum (When In Use)
- Fotoğraflar (Add)
- Mikrofon (video)

---

## İletişim

Geliştirici: [Metin Faruk Bıyık](https://biyik.dev)  
Destek: metin@biyik.dev
