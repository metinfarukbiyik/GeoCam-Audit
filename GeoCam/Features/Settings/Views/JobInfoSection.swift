//
//  JobInfoSection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Kurumsal iş emri, site kimliği ve konu notu tercihleri.
struct JobInfoSection: View {

    @Environment(\.appLanguage) private var language

    @Binding var enabledFields: Set<OverlayField>
    @Binding var workOrderNumber: String
    @Binding var siteID: String
    @Binding var jobSubject: String

    var body: some View {
        Section {
            jobField(
                field: .workOrder,
                text: $workOrderNumber,
                prompt: language.t(.jobWorkOrderPrompt)
            )

            jobField(
                field: .siteID,
                text: $siteID,
                prompt: language.t(.jobSitePrompt)
            )

            jobField(
                field: .jobSubject,
                text: $jobSubject,
                prompt: language.t(.jobSubjectPrompt),
                axis: .vertical,
                autocapitalization: .sentences
            )

            if hasAnyValue {
                Button(language.t(.settingsClearJobInfo), role: .destructive) {
                    workOrderNumber = ""
                    siteID = ""
                    jobSubject = ""
                }
            }
        } header: {
            Text(language.t(.settingsJobInfo))
        } footer: {
            Text(language.t(.settingsJobInfoFooter))
        }
    }

    private var hasAnyValue: Bool {
        !workOrderNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !siteID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !jobSubject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func jobField(
        field: OverlayField,
        text: Binding<String>,
        prompt: String,
        axis: Axis = .horizontal,
        autocapitalization: TextInputAutocapitalization = .characters
    ) -> some View {
        VStack(alignment: .leading, spacing: LayoutConstants.Spacing.small) {
            Toggle(isOn: binding(for: field)) {
                Label(field.title(language: language), systemImage: field.systemImageName)
            }

            TextField(prompt, text: text, axis: axis)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(axis != .vertical)
                .lineLimit(axis == .vertical ? 2...4 : 1...1)
                .onChange(of: text.wrappedValue) { _, newValue in
                    // Değer yazılınca ilgili satırı otomatik aç.
                    if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        enabledFields.insert(field)
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
    @Previewable @State var fields: Set<OverlayField> = [.workOrder]
    @Previewable @State var workOrder = "WO-2026-0142"
    @Previewable @State var site = ""
    @Previewable @State var subject = ""

    return Form {
        JobInfoSection(
            enabledFields: $fields,
            workOrderNumber: $workOrder,
            siteID: $site,
            jobSubject: $subject
        )
    }
}
