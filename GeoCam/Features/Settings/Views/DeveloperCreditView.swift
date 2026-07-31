//
//  DeveloperCreditView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Ayarlar listesinin sonunda gösterilen geliştirici künyesi.
struct DeveloperCreditView: View {
    @Environment(\.appLanguage) private var language

    var body: some View {
        Text(.init(creditMarkdown))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Ad, Markdown bağlantısı olarak verilir; böylece metin dar alanda da doğal biçimde sarılır.
    private var creditMarkdown: String {
        let name = AppConstants.Info.developerName
        let suffix = language.t(.settingsDeveloperCredit)

        guard let url = AppConstants.Info.developerURL else { return "\(name) \(suffix)" }

        return "[\(name)](\(url.absoluteString)) \(suffix)"
    }
}

#Preview {
    DeveloperCreditView()
        .padding()
}
