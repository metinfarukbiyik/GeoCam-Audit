//
//  ContactSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Destek iletişimi ve App Store puanlama bölümü.
struct ContactSection: View {
    @Environment(\.appLanguage) private var language

    var body: some View {
        Section {
            if let mailURL = AppConstants.ExternalLink.supportMail(language: language) {
                Link(destination: mailURL) {
                    Label(language.t(.settingsContactLink), systemImage: "envelope")
                }
            }

            if let reviewURL = AppConstants.ExternalLink.appStoreReview {
                Link(destination: reviewURL) {
                    Label(language.t(.settingsRateLink), systemImage: "star")
                }
            }
        } header: {
            Text(language.t(.settingsSupport))
        }
    }
}

#Preview {
    Form {
        ContactSection()
    }
}
