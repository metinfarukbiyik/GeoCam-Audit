//
//  AppearanceSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Tema, yazı tipi, kenar konumu ve katman boyutu tercihlerini sunan bölüm.
struct AppearanceSection: View {
    @Environment(\.appLanguage) private var language

    @Binding var layoutStyle: OverlayLayoutStyle
    @Binding var theme: AppTheme
    @Binding var fontStyle: OverlayFontStyle
    @Binding var textSize: OverlayTextSize
    @Binding var corner: OverlayCorner
    @Binding var overlayScale: CGFloat

    var body: some View {
        Section {
            Picker(language.t(.settingsLayout), selection: $layoutStyle) {
                ForEach(OverlayLayoutStyle.allCases) { style in
                    Text(style.title(language: language)).tag(style)
                }
            }

            Picker(language.t(.settingsTheme), selection: $theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.title(language: language)).tag(theme)
                }
            }

            Picker(language.t(.settingsFont), selection: $fontStyle) {
                ForEach(OverlayFontStyle.allCases) { style in
                    Text(style.title(language: language))
                        .fontDesign(style.design)
                        .tag(style)
                }
            }

            Picker(language.t(.settingsTextSize), selection: $textSize) {
                ForEach(OverlayTextSize.allCases) { size in
                    Text(size.title(language: language)).tag(size)
                }
            }
            .pickerStyle(.segmented)

            cornerPicker

            overlayScaleRow
        } header: {
            Text(language.t(.settingsAppearance))
        }
    }

    /// Yalnızca sol / sağ kenar; dikey konum kamera sürüklemesiyle ayarlanır.
    private var cornerPicker: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.small) {
            Text(language.t(.settingsCorner))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: LayoutConstants.Spacing.small) {
                ForEach(OverlayCorner.allCases) { value in
                    cornerButton(value)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func cornerButton(_ value: OverlayCorner) -> some View {
        let isSelected = corner == value

        return Button {
            corner = value
        } label: {
            Text(value.title(language: language))
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .frame(maxWidth: .infinity)
                .padding(.vertical, LayoutConstants.Spacing.small)
                .background {
                    RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous)
                        .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous)
                        .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 1.5)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var overlayScaleRow: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.extraSmall) {
            HStack {
                Text(language.t(.settingsOverlayScale))

                Spacer(minLength: LayoutConstants.Spacing.small)

                Text(verbatim: "%\(percentage)")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Slider(
                value: scaleBinding,
                in: OverlayConstants.Scale.minimum...OverlayConstants.Scale.maximum,
                step: 0.01
            ) {
                Text(language.t(.settingsOverlayScale))
            } minimumValueLabel: {
                Image(systemName: "rectangle.compress.vertical")
            } maximumValueLabel: {
                Image(systemName: "rectangle.expand.vertical")
            }
            .accessibilityValue(Text(verbatim: "%\(percentage)"))
        }
    }

    /// Yazma sırasında aralığa sıkıştırır; Binding kopması yüzünden değerin kaybolmasını engeller.
    private var scaleBinding: Binding<CGFloat> {
        Binding(
            get: { OverlayConstants.Scale.clamped(overlayScale) },
            set: { overlayScale = OverlayConstants.Scale.clamped($0) }
        )
    }

    private var percentage: Int {
        Int((OverlayConstants.Scale.clamped(overlayScale) * 100).rounded())
    }
}

#Preview {
    @Previewable @State var layoutStyle = OverlayLayoutStyle.card
    @Previewable @State var theme = AppTheme.system
    @Previewable @State var fontStyle = OverlayFontStyle.rounded
    @Previewable @State var textSize = OverlayTextSize.medium
    @Previewable @State var corner = OverlayCorner.leading
    @Previewable @State var overlayScale: CGFloat = 1

    return Form {
        AppearanceSection(
            layoutStyle: $layoutStyle,
            theme: $theme,
            fontStyle: $fontStyle,
            textSize: $textSize,
            corner: $corner,
            overlayScale: $overlayScale
        )
    }
}
