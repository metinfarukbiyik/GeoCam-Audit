//
//  JobInfoSheet.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Kamera ekranından iş emri / site / not bilgisini hızlı güncelleme paneli.
struct JobInfoSheet: View {

    @Environment(\.appLanguage) private var language

    @Binding var settings: OverlaySettings
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    labeledField(
                        title: OverlayField.workOrder.title(language: language),
                        systemImage: OverlayField.workOrder.systemImageName,
                        text: $settings.workOrderNumber,
                        prompt: language.t(.jobWorkOrderPrompt),
                        field: .workOrder
                    )

                    labeledField(
                        title: OverlayField.siteID.title(language: language),
                        systemImage: OverlayField.siteID.systemImageName,
                        text: $settings.siteID,
                        prompt: language.t(.jobSitePrompt),
                        field: .siteID
                    )

                    labeledField(
                        title: OverlayField.jobSubject.title(language: language),
                        systemImage: OverlayField.jobSubject.systemImageName,
                        text: $settings.jobSubject,
                        prompt: language.t(.jobSubjectPrompt),
                        field: .jobSubject,
                        axis: .vertical
                    )
                } footer: {
                    Text(language.t(.jobSheetFooter))
                }

                if settings.hasJobInfoContent {
                    Section {
                        Button(language.t(.settingsClearJobInfo), role: .destructive) {
                            settings.clearJobInfo()
                        }
                    }
                }
            }
            .navigationTitle(language.t(.settingsJobInfo))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(language.t(.jobSheetDone), action: onDismiss)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func labeledField(
        title: String,
        systemImage: String,
        text: Binding<String>,
        prompt: String,
        field: OverlayField,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.extraSmall) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(prompt, text: text, axis: axis)
                .textInputAutocapitalization(axis == .vertical ? .sentences : .characters)
                .autocorrectionDisabled(axis != .vertical)
                .lineLimit(axis == .vertical ? 2...4 : 1...1)
                .onChange(of: text.wrappedValue) { _, newValue in
                    // Değer yazılınca ilgili satırı otomatik aç.
                    if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        settings.enabledFields.insert(field)
                    }
                }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    @Previewable @State var settings = OverlaySettings.default

    return JobInfoSheet(settings: $settings, onDismiss: {})
}
