//
//  ContactSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Hata bildirimi ve öneriler için iletişim bölümü.
struct ContactSection: View {
    @Environment(\.appLanguage) private var language

    var body: some View {
        Section {
            if let url = AppConstants.ExternalLink.supportMail(language: language) {
                Link(destination: url) {
                    Label(language.t(.settingsContactLink), systemImage: "envelope.fill")
                }
            }
        } header: {
            Text(language.t(.settingsSupport))
        } footer: {
            Text(language.t(.settingsContactFooter, AppConstants.Info.supportEmail))
        }
    }
}

#Preview {
    Form {
        ContactSection()
    }
}
