//
//  AppearanceSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Tema, yazı tipi ve metin boyutu tercihlerini sunan bölüm.
struct AppearanceSection: View {
    @Binding var layoutStyle: OverlayLayoutStyle
    @Binding var theme: AppTheme
    @Binding var fontStyle: OverlayFontStyle
    @Binding var textSize: OverlayTextSize

    var body: some View {
        Section {
            Picker("Katman Tasarımı", selection: $layoutStyle) {
                ForEach(OverlayLayoutStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }

            Picker("Tema", selection: $theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.title).tag(theme)
                }
            }

            Picker("Yazı Tipi", selection: $fontStyle) {
                ForEach(OverlayFontStyle.allCases) { style in
                    Text(style.title)
                        .fontDesign(style.design)
                        .tag(style)
                }
            }

            Picker("Metin Boyutu", selection: $textSize) {
                ForEach(OverlayTextSize.allCases) { size in
                    Text(size.title).tag(size)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Görünüm")
        } footer: {
            Text("Tasarım seçimi kamera önizlemesine anında yansır. Bilgi katmanını parmağınızla sürükleyerek fotoğraftaki yerini değiştirebilirsiniz.")
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
