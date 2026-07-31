//
//  RootView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Uygulamanın kök navigasyon kabuğu.
/// Soğuk açılışta markalı splash gösterilir; ardından kamera çekmecesi sunulur.
struct RootView: View {

    @Environment(AppDependencies.self) private var dependencies
    @State private var isMenuPresented = false
    @State private var isSplashVisible = true

    var body: some View {
        ZStack {
            SideMenuContainer(isPresented: $isMenuPresented) {
                NavigationStack {
                    CameraView(
                        viewModel: dependencies.makeCameraViewModel(),
                        locationViewModel: dependencies.makeLocationViewModel(),
                        onOpenMenu: { isMenuPresented = true }
                    )
                }
            } menu: {
                SettingsView(
                    viewModel: dependencies.makeSettingsViewModel(),
                    onClose: { isMenuPresented = false }
                )
            }
            .opacity(isSplashVisible ? 0 : 1)

            if isSplashVisible {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(dependencies.settingsStore.settings.theme.colorScheme)
        .environment(\.appLanguage, dependencies.settingsStore.settings.appLanguage)
        .environment(\.locale, dependencies.settingsStore.settings.appLanguage.locale)
        .task { await dismissSplash() }
    }

    private func dismissSplash() async {
        try? await Task.sleep(for: .seconds(AppConstants.Feedback.splashDuration))

        withAnimation(.easeInOut(duration: AppConstants.Animation.standard)) {
            isSplashVisible = false
        }
    }
}

#Preview {
    RootView()
        .environment(AppDependencies())
}
