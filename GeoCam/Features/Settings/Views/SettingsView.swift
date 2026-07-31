//
//  SettingsView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Kullanıcı tercihlerinin düzenlendiği, soldan açılan menü içeriği.
struct SettingsView: View {

    @State private var viewModel: SettingsViewModel
    private let onClose: () -> Void

    init(viewModel: SettingsViewModel, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onClose = onClose
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                CameraSection(
                    aspectRatio: $viewModel.settings.aspectRatio,
                    savesOriginalPhoto: $viewModel.settings.savesOriginalPhoto
                )

                JobInfoSection(
                    enabledFields: $viewModel.settings.enabledFields,
                    workOrderNumber: $viewModel.settings.workOrderNumber,
                    siteID: $viewModel.settings.siteID,
                    jobSubject: $viewModel.settings.jobSubject
                )

                OverlayFieldsSection(enabledFields: $viewModel.settings.enabledFields)

                BrandingSection(
                    showsBranding: $viewModel.settings.showsBranding,
                    brandName: $viewModel.settings.brandName,
                    brandFontStyle: $viewModel.settings.brandFontStyle,
                    brandAccentColor: $viewModel.settings.brandAccentColor,
                    brandIcon: $viewModel.settings.brandIcon,
                    logo: viewModel.logo,
                    onLogoChange: viewModel.updateLogo
                )

                AppearanceSection(
                    layoutStyle: $viewModel.settings.layoutStyle,
                    theme: $viewModel.settings.theme,
                    fontStyle: $viewModel.settings.fontStyle,
                    textSize: $viewModel.settings.textSize
                )

                ContactSection()

                Section {
                    Button("Varsayılana Dön", role: .destructive) {
                        viewModel.resetToDefaults()
                    }
                }

                Section {
                    DeveloperCreditView()
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bitti", action: onClose)
                }
            }
        }
    }
}

#Preview {
    SettingsView(
        viewModel: AppDependencies().makeSettingsViewModel(),
        onClose: {}
    )
}
