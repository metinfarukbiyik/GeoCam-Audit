//
//  PermissionRequestView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// İzin verilmediğinde kullanıcıyı bilgilendiren ve Ayarlar'a yönlendiren ekran.
struct PermissionRequestView: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(message)
        } actions: {
            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    PermissionRequestView(
        systemImage: "camera.fill",
        title: "Kamera Erişimi Gerekli",
        message: "Fotoğraf çekebilmek için kamera iznine ihtiyaç var.",
        actionTitle: "Ayarları Aç",
        action: {}
    )
}
