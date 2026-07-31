//
//  GeoCamApp.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

@main
struct GeoCamApp: App {

    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                // Sistem launch ile SwiftUI splash arasında yeşil/siyah flaş olmasın.
                .background(Color(red: 0.02, green: 0.11, blue: 0.212))
        }
    }
}
