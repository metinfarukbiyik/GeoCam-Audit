//
//  SettingsView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Kullanıcı tercihlerinin düzenlendiği ayarlar sayfası.
/// Değişiklikler Bitti ile kaydedilir; kapatılırsa taslak atılır.
struct SettingsView: View {

    @Bindable var viewModel: SettingsViewModel
    private let onDone: () -> Void

    init(viewModel: SettingsViewModel, onDone: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDone = onDone
    }

    var body: some View {
        let language = viewModel.draft.appLanguage

        NavigationStack {
            Form {
                LanguageSection(language: $viewModel.draft.appLanguage)

                CameraSection(
                    aspectRatio: $viewModel.draft.aspectRatio,
                    savesOriginalPhoto: $viewModel.draft.savesOriginalPhoto
                )

                JobInfoSection(
                    enabledFields: $viewModel.draft.enabledFields,
                    workOrderNumber: $viewModel.draft.workOrderNumber,
                    siteID: $viewModel.draft.siteID,
                    jobSubject: $viewModel.draft.jobSubject
                )

                OverlayFieldsSection(enabledFields: $viewModel.draft.enabledFields)

                BrandingSection(
                    showsBranding: $viewModel.draft.showsBranding,
                    brandName: $viewModel.draft.brandName,
                    brandFontStyle: $viewModel.draft.brandFontStyle,
                    brandAccentColor: $viewModel.draft.brandAccentColor,
                    brandIcon: $viewModel.draft.brandIcon,
                    logo: viewModel.draftLogo,
                    onLogoChange: viewModel.updateDraftLogo
                )

                AppearanceSection(
                    layoutStyle: $viewModel.draft.layoutStyle,
                    theme: $viewModel.draft.theme,
                    fontStyle: $viewModel.draft.fontStyle,
                    textSize: $viewModel.draft.textSize,
                    corner: $viewModel.draft.corner,
                    overlayScale: $viewModel.draft.overlayScale
                )

                ContactSection()

                Section {
                    Button(language.t(.settingsReset), role: .destructive) {
                        viewModel.resetDraftToDefaults()
                    }
                } footer: {
                    DeveloperCreditView()
                        .padding(.top, LayoutConstants.Spacing.small)
                }
            }
            .navigationTitle(language.t(.settingsTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(language.t(.settingsDone)) {
                        viewModel.save()
                        onDone()
                    }
                    .fontWeight(.semibold)
                }
            }
            // Dil taslakta seçilince form metinleri de güncellensin.
            .environment(\.appLanguage, language)
            .environment(\.locale, language.locale)
        }
    }
}

#Preview {
    SettingsView(
        viewModel: AppDependencies().makeSettingsViewModel(),
        onDone: {}
    )
}
