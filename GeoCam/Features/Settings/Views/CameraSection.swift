//
//  CameraSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Çekim çerçevesi ve kayıt tercihlerini sunan bölüm.
struct CameraSection: View {

    @Environment(\.appLanguage) private var language

    @Binding var aspectRatio: CameraAspectRatio
    @Binding var savesOriginalPhoto: Bool

    var body: some View {
        Section {
            Picker(language.t(.settingsFrameRatio), selection: $aspectRatio) {
                ForEach(CameraAspectRatio.allCases) { ratio in
                    Text(ratio.title).tag(ratio)
                }
            }
            .pickerStyle(.segmented)

            Toggle(isOn: $savesOriginalPhoto) {
                Label(language.t(.settingsSaveOriginal), systemImage: "square.on.square")
            }
        } header: {
            Text(language.t(.settingsCamera))
        } footer: {
            Text(language.t(.settingsCameraFooter))
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
