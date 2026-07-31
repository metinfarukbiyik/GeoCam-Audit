//
//  OverlayFieldsSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Fotoğrafta hangi bilgilerin gösterileceğini seçtiren bölüm.
/// Kurumsal iş alanları ayrı İş Bilgisi bölümünde yönetilir.
struct OverlayFieldsSection: View {
    @Environment(\.appLanguage) private var language
    @Binding var enabledFields: Set<OverlayField>

    private var sensorFields: [OverlayField] {
        OverlayField.allCases.filter { !$0.isJobInfoField }
    }

    var body: some View {
        Section(language.t(.settingsOverlayFields)) {
            ForEach(sensorFields) { field in
                Toggle(isOn: binding(for: field)) {
                    Label(field.title(language: language), systemImage: field.systemImageName)
                }
            }
        }
    }

    private func binding(for field: OverlayField) -> Binding<Bool> {
        Binding(
            get: { enabledFields.contains(field) },
            set: { isEnabled in
                if isEnabled {
                    enabledFields.insert(field)
                } else {
                    enabledFields.remove(field)
                }
            }
        )
    }
}

#Preview {
    @Previewable @State var fields = Set(OverlayField.allCases)
    return Form {
        OverlayFieldsSection(enabledFields: $fields)
    }
}
