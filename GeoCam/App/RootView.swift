//
//  RootView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Uygulamanın kök navigasyon kabuğu: kamera + sol ayarlar çekmecesi.
struct RootView: View {

    @Environment(AppDependencies.self) private var dependencies
    @State private var isMenuPresented = false
    @State private var cameraViewModel: CameraViewModel
    @State private var locationViewModel: LocationViewModel
    @State private var settingsViewModel: SettingsViewModel

    init(dependencies: AppDependencies) {
        _cameraViewModel = State(initialValue: dependencies.makeCameraViewModel())
        _locationViewModel = State(initialValue: dependencies.makeLocationViewModel())
        _settingsViewModel = State(initialValue: dependencies.makeSettingsViewModel())
    }

    var body: some View {
        SideMenuContainer(isPresented: $isMenuPresented) {
            NavigationStack {
                CameraView(
                    viewModel: cameraViewModel,
                    locationViewModel: locationViewModel,
                    onOpenMenu: { isMenuPresented = true }
                )
            }
        } menu: {
            SettingsView(
                viewModel: settingsViewModel,
                onClose: { isMenuPresented = false }
            )
        }
        .background(Color.black)
        .preferredColorScheme(dependencies.settingsStore.settings.theme.colorScheme)
        .environment(\.appLanguage, dependencies.settingsStore.settings.appLanguage)
        .environment(\.locale, dependencies.settingsStore.settings.appLanguage.locale)
    }
}

#Preview {
    let dependencies = AppDependencies()
    return RootView(dependencies: dependencies)
        .environment(dependencies)
}
