//
//  GeoCamApp.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Observation
import SwiftUI

@main
struct GeoCamApp: App {

    var body: some Scene {
        WindowGroup {
            AppBootstrapView()
                .background(Color.black)
        }
    }
}

/// Açılış durumunu referans tipte tutar; SwiftUI View kopyalarında `@State` kaybı olmaz.
@MainActor
@Observable
private final class AppBootstrapModel {

    var dependencies: AppDependencies?
    var isSplashVisible = true

    private var didStart = false

    func startIfNeeded() {
        guard !didStart else { return }
        didStart = true

        // Yapılandırılmamış Task: SwiftUI `.task` gibi Observation ile iptal edilmez.
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(AppConstants.Feedback.splashDuration))

            // Önce splash’i kapat; DI yavaş/takılırsa açılış ekranında kalınmasın.
            withAnimation(.easeInOut(duration: AppConstants.Animation.standard)) {
                isSplashVisible = false
            }

            await Task.yield()

            if dependencies == nil {
                dependencies = AppDependencies()
            }
        }
    }
}

/// 1) Yalnızca splash  2) Süre bitince DI + ana arayüz
private struct AppBootstrapView: View {

    @State private var model = AppBootstrapModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let dependencies = model.dependencies {
                RootView(dependencies: dependencies)
                    .environment(dependencies)
                    .opacity(model.isSplashVisible ? 0 : 1)
            }

            if model.isSplashVisible {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            model.startIfNeeded()
        }
    }
}
