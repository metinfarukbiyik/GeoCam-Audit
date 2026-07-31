//
//  ContactSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Hata bildirimi ve öneriler için iletişim bölümü.
struct ContactSection: View {

    var body: some View {
        Section {
            if let url = AppConstants.ExternalLink.supportMail {
                Link(destination: url) {
                    Label("İletişime Geç", systemImage: "envelope.fill")
                }
            }
        } header: {
            Text("Destek")
        } footer: {
            Text("Hata bildirimi ve iyileştirme önerileriniz için \(AppConstants.Info.supportEmail) adresine yazabilirsiniz.")
        }
    }
}

#Preview {
    Form {
        ContactSection()
    }
}
