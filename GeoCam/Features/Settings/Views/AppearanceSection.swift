//
//  AppearanceSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Tema, yazı tipi ve metin boyutu tercihlerini sunan bölüm.
struct AppearanceSection: View {
    @Environment(\.appLanguage) private var language

    @Binding var layoutStyle: OverlayLayoutStyle
    @Binding var theme: AppTheme
    @Binding var fontStyle: OverlayFontStyle
    @Binding var textSize: OverlayTextSize
    @Binding var horizontalAlignment: OverlayHorizontalAlignment
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

            Picker(language.t(.settingsAlignment), selection: $horizontalAlignment) {
                ForEach(OverlayHorizontalAlignment.allCases) { alignment in
                    Text(alignment.title(language: language)).tag(alignment)
                }
            }
            .pickerStyle(.segmented)

            overlayScaleRow
        } header: {
            Text(language.t(.settingsAppearance))
        } footer: {
            Text(language.t(.settingsAppearanceFooter))
        }
    }

    /// Tasarımın tamamını küçültür; kamera ekranındaki çift parmak jestiyle aynı değeri yazar.
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
                value: $overlayScale,
                in: OverlayConstants.Scale.minimum...OverlayConstants.Scale.maximum
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

    private var percentage: Int {
        Int((OverlayConstants.Scale.clamped(overlayScale) * 100).rounded())
    }
}

#Preview {
    @Previewable @State var layoutStyle = OverlayLayoutStyle.card
    @Previewable @State var theme = AppTheme.system
    @Previewable @State var fontStyle = OverlayFontStyle.rounded
    @Previewable @State var textSize = OverlayTextSize.medium
    @Previewable @State var alignment = OverlayHorizontalAlignment.leading
    @Previewable @State var overlayScale: CGFloat = 1

    return Form {
        AppearanceSection(
            layoutStyle: $layoutStyle,
            theme: $theme,
            fontStyle: $fontStyle,
            textSize: $textSize,
            horizontalAlignment: $alignment,
            overlayScale: $overlayScale
        )
    }
}
