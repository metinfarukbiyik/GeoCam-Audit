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
        } header: {
            Text(language.t(.settingsAppearance))
        } footer: {
            Text(language.t(.settingsAppearanceFooter))
        }
    }
}

#Preview {
    @Previewable @State var layoutStyle = OverlayLayoutStyle.card
    @Previewable @State var theme = AppTheme.system
    @Previewable @State var fontStyle = OverlayFontStyle.rounded
    @Previewable @State var textSize = OverlayTextSize.medium

    return Form {
        AppearanceSection(
            layoutStyle: $layoutStyle,
            theme: $theme,
            fontStyle: $fontStyle,
            textSize: $textSize
        )
    }
}
