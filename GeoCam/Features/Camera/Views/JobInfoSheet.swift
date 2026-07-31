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
                        text: workOrderBinding,
                        prompt: language.t(.jobWorkOrderPrompt)
                    )

                    labeledField(
                        title: OverlayField.siteID.title(language: language),
                        systemImage: OverlayField.siteID.systemImageName,
                        text: siteIDBinding,
                        prompt: language.t(.jobSitePrompt)
                    )

                    labeledField(
                        title: OverlayField.jobSubject.title(language: language),
                        systemImage: OverlayField.jobSubject.systemImageName,
                        text: subjectBinding,
                        prompt: language.t(.jobSubjectPrompt),
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

    private var workOrderBinding: Binding<String> {
        fieldBinding(
            get: { settings.workOrderNumber },
            set: { settings.workOrderNumber = $0 },
            field: .workOrder
        )
    }

    private var siteIDBinding: Binding<String> {
        fieldBinding(
            get: { settings.siteID },
            set: { settings.siteID = $0 },
            field: .siteID
        )
    }

    private var subjectBinding: Binding<String> {
        fieldBinding(
            get: { settings.jobSubject },
            set: { settings.jobSubject = $0 },
            field: .jobSubject
        )
    }

    private func fieldBinding(
        get: @escaping () -> String,
        set: @escaping (String) -> Void,
        field: OverlayField
    ) -> Binding<String> {
        Binding(
            get: get,
            set: { newValue in
                set(newValue)
                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    settings.enabledFields.insert(field)
                }
            }
        )
    }

    private func labeledField(
        title: String,
        systemImage: String,
        text: Binding<String>,
        prompt: String,
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
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    @Previewable @State var settings = OverlaySettings.default

    return JobInfoSheet(settings: $settings, onDismiss: {})
}
