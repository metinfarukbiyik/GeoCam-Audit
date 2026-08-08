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
            HStack(spacing: LayoutConstants.Spacing.small) {
                if let mailURL = AppConstants.ExternalLink.supportMail(language: language) {
                    actionLink(
                        title: language.t(.settingsContactLink),
                        systemImage: "envelope.fill",
                        destination: mailURL
                    )
                }

                if let reviewURL = AppConstants.ExternalLink.appStoreReview {
                    actionLink(
                        title: language.t(.settingsRateLink),
                        systemImage: "star.fill",
                        destination: reviewURL
                    )
                }
            }
            .listRowInsets(
                EdgeInsets(
                    top: LayoutConstants.Spacing.small,
                    leading: LayoutConstants.Spacing.medium,
                    bottom: LayoutConstants.Spacing.small,
                    trailing: LayoutConstants.Spacing.medium
                )
            )
        } header: {
            Text(language.t(.settingsSupport))
        } footer: {
            Text(language.t(.settingsContactFooter, AppConstants.Info.supportEmail))
        }
    }

    private func actionLink(
        title: String,
        systemImage: String,
        destination: URL
    ) -> some View {
        Link(destination: destination) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, LayoutConstants.Spacing.small)
                .background {
                    RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous)
                        .fill(Color.accentColor.opacity(0.14))
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    Form {
        ContactSection()
    }
}
