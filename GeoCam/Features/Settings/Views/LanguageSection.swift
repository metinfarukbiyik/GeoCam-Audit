//
//  LanguageSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Uygulama dili seçimi.
struct LanguageSection: View {
    @Binding var language: AppLanguage

    var body: some View {
        Section {
            Picker(selection: $language) {
                ForEach(AppLanguage.allCases) { option in
                    Text(option.nativeTitle).tag(option)
                }
            } label: {
                Label(language.t(.settingsLanguage), systemImage: "globe")
            }
        } header: {
            Text(language.t(.settingsLanguage))
        } footer: {
            Text(language.t(.settingsLanguageFooter))
        }
    }
}

#Preview {
    @Previewable @State var language = AppLanguage.turkish

    return Form {
        LanguageSection(language: $language)
    }
}
