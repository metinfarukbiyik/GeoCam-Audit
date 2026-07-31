//
//  CameraSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Çekim çerçevesi ve kayıt tercihlerini sunan bölüm.
struct CameraSection: View {

    @Binding var aspectRatio: CameraAspectRatio
    @Binding var savesOriginalPhoto: Bool

    var body: some View {
        Section {
            Picker("Çerçeve Oranı", selection: $aspectRatio) {
                ForEach(CameraAspectRatio.allCases) { ratio in
                    Text(ratio.title).tag(ratio)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $savesOriginalPhoto) {
                Label("Orijinali de Kaydet", systemImage: "square.on.square")
            }
        } header: {
            Text("Kamera")
        } footer: {
            Text("9:16 tam ekran önizleme sunar; 4:3 seçildiğinde çekim alanı küçültülerek çerçeve net görünür. Orijinali de kaydet açıkken damgasız kopya aynı çerçeve oranında Fotoğraflar’a yazılır.")
        }
    }
}

#Preview {
    @Previewable @State var aspectRatio = CameraAspectRatio.standard
    @Previewable @State var savesOriginal = false

    return Form {
        CameraSection(
            aspectRatio: $aspectRatio,
            savesOriginalPhoto: $savesOriginal
        )
    }
}
