//
//  RootView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Uygulamanın kök navigasyon kabuğu: kamera + ayarlar sayfası.
struct RootView: View {

    @Environment(AppDependencies.self) private var dependencies
    @State private var isSettingsPresented = false
    @State private var cameraViewModel: CameraViewModel
    @State private var locationViewModel: LocationViewModel
    @State private var settingsViewModel: SettingsViewModel

    init(dependencies: AppDependencies) {
        _cameraViewModel = State(initialValue: dependencies.makeCameraViewModel())
        _locationViewModel = State(initialValue: dependencies.makeLocationViewModel())
        _settingsViewModel = State(initialValue: dependencies.makeSettingsViewModel())
    }

    var body: some View {
        NavigationStack {
            CameraView(
                viewModel: cameraViewModel,
                locationViewModel: locationViewModel,
                onOpenSettings: openSettings
            )
        }
        .background(Color.black)
        .preferredColorScheme(dependencies.settingsStore.settings.theme.colorScheme)
        .environment(\.appLanguage, dependencies.settingsStore.settings.appLanguage)
        .environment(\.locale, dependencies.settingsStore.settings.appLanguage.locale)
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(
                viewModel: settingsViewModel,
                onDone: {
                    isSettingsPresented = false
                }
            )
            // Tema taslakta değişebilir; sheet kendi tercihini taşır.
            .preferredColorScheme(settingsViewModel.draft.theme.colorScheme)
            .presentationDragIndicator(.visible)
        }
    }

    private func openSettings() {
        settingsViewModel.prepareForPresentation()
        isSettingsPresented = true
    }
}

#Preview {
    let dependencies = AppDependencies()
    return RootView(dependencies: dependencies)
        .environment(dependencies)
}
