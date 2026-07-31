//
//  BrandingSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import PhotosUI
import SwiftUI

/// Şirket logosu, marka adı, font, renk ve ikon tercihlerini sunan bölüm.
struct BrandingSection: View {

    @Binding var showsBranding: Bool
    @Binding var brandName: String
    @Binding var brandFontStyle: BrandFontStyle
    @Binding var brandAccentColor: BrandAccentColor
    @Binding var brandIcon: BrandIcon
    let logo: UIImage?
    let onLogoChange: (UIImage?) -> Void

    @State private var pickerSelection: PhotosPickerItem?

    private let iconColumns = [
        GridItem(.adaptive(minimum: 44), spacing: LayoutConstants.Spacing.small)
    ]

    var body: some View {
        Section {
            Toggle(isOn: $showsBranding) {
                Label("Fotoğrafa Marka Ekle", systemImage: "signature")
            }

            TextField("Şirket / Marka Adı", text: $brandName)
                .textInputAutocapitalization(.words)

            if showsBranding {
                styleControls
                iconPicker
                logoRow

                if logo != nil {
                    Button("Logoyu Kaldır", role: .destructive) {
                        onLogoChange(nil)
                    }
                }
            }
        } header: {
            Text("Marka")
        } footer: {
            Text("Logo veya ikon ile marka adı, canlı önizlemede ve kaydedilen fotoğrafta bilgi katmanının en üstünde görünür. Özel logo seçildiğinde ikon yerine logo kullanılır.")
        }
        .onChange(of: pickerSelection) { _, item in
            Task { await loadLogo(from: item) }
        }
        .onChange(of: brandName) { _, name in
            // Ad yazılınca markayı otomatik aç; kullanıcı kapattıysa zorlamayız.
            if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !showsBranding {
                showsBranding = true
            }
        }
    }

    @ViewBuilder
    private var styleControls: some View {
        Picker("Marka Yazı Tipi", selection: $brandFontStyle) {
            ForEach(BrandFontStyle.allCases) { style in
                Text(style.title)
                    .font(.body.weight(style.weight).width(style.width))
                    .fontDesign(style.design)
                    .tag(style)
            }
        }

        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.small) {
            Text("Marka Rengi")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            colorPicker

            previewChip
        }
    }

    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LayoutConstants.Spacing.small) {
                ForEach(BrandAccentColor.allCases) { accent in
                    Button {
                        brandAccentColor = accent
                    } label: {
                        Circle()
                            .fill(accent.color)
                            .frame(width: 28, height: 28)
                            .overlay {
                                Circle()
                                    .strokeBorder(.primary.opacity(0.2), lineWidth: 1)
                            }
                            .overlay {
                                if brandAccentColor == accent {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(accent == .white ? .black : .white)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accent.title)
                    .accessibilityAddTraits(brandAccentColor == accent ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var previewChip: some View {
        HStack(spacing: LayoutConstants.Spacing.small) {
            if logo == nil, let symbol = brandIcon.systemImageName {
                Image(systemName: symbol)
            }

            Text(brandName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                 ? "Marka Önizleme"
                 : brandName)
                .lineLimit(1)
        }
        .font(
            .system(
                size: 16,
                weight: brandFontStyle.weight,
                design: brandFontStyle.design
            )
            .width(brandFontStyle.width)
        )
        .foregroundStyle(brandAccentColor.color)
        .padding(.horizontal, LayoutConstants.Spacing.medium)
        .padding(.vertical, LayoutConstants.Spacing.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small))
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.small) {
            Text("Marka İkonu")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: iconColumns, spacing: LayoutConstants.Spacing.small) {
                ForEach(BrandIcon.allCases) { icon in
                    Button {
                        brandIcon = icon
                    } label: {
                        Group {
                            if let symbol = icon.systemImageName {
                                Image(systemName: symbol)
                                    .font(.body.weight(.semibold))
                            } else {
                                Image(systemName: "slash.circle")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small)
                                .fill(brandIcon == icon ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.12))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small)
                                .strokeBorder(
                                    brandIcon == icon ? Color.accentColor : .clear,
                                    lineWidth: 1.5
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(brandAccentColor.color)
                    .accessibilityLabel(icon.title)
                    .accessibilityAddTraits(brandIcon == icon ? .isSelected : [])
                }
            }

            if logo != nil {
                Text("Özel logo seçiliyken ikon gizlenir.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var logoRow: some View {
        HStack(spacing: LayoutConstants.Spacing.medium) {
            logoPreview

            PhotosPicker(
                logo == nil ? "Logo Seç" : "Logoyu Değiştir",
                selection: $pickerSelection,
                matching: .images,
                photoLibrary: .shared()
            )
        }
    }

    @ViewBuilder
    private var logoPreview: some View {
        let side = LayoutConstants.Branding.logoPreviewSize

        if let logo {
            Image(uiImage: logo)
                .resizable()
                .scaledToFit()
                .frame(width: side, height: side)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: side, height: side)
                .accessibilityHidden(true)
        }
    }

    private func loadLogo(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data)
        else { return }

        onLogoChange(image.downscaled(toMaxDimension: LayoutConstants.Branding.maxLogoDimension))
    }
}

#Preview {
    @Previewable @State var showsBranding = true
    @Previewable @State var brandName = "GeoCam Yapı"
    @Previewable @State var font = BrandFontStyle.rounded
    @Previewable @State var color = BrandAccentColor.yellow
    @Previewable @State var icon = BrandIcon.building

    return Form {
        BrandingSection(
            showsBranding: $showsBranding,
            brandName: $brandName,
            brandFontStyle: $font,
            brandAccentColor: $color,
            brandIcon: $icon,
            logo: nil,
            onLogoChange: { _ in }
        )
    }
}
