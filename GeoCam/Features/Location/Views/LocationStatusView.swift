//
//  LocationStatusView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Kamera ekranında canlı bilgi katmanını gösterir.
/// Bilgi durumunda InfoOverlayView kullanıldığı için önizleme,
/// fotoğrafa basılacak katmanla birebir aynıdır.
struct LocationStatusView: View {

    let viewModel: LocationViewModel
    let settings: OverlaySettings
    let branding: OverlayBranding?
    let maxWidth: CGFloat
    let onOpenSettings: () -> Void

    var body: some View {
        if viewModel.permissionStatus.requiresSettingsRedirect {
            statusCard { permissionRow }
        } else if isAwaitingFirstFix && branding == nil {
            statusCard { searchingRow }
        } else if shouldShowOverlay {
            InfoOverlayView(
                metadata: viewModel.currentMetadata,
                settings: settings,
                branding: branding,
                chromeStyle: .live,
                maxWidth: maxWidth
            )
        }
    }

    /// Konuma bağlı alanlar açıkken ilk ölçüm gelene kadar arama durumu gösterilir.
    private var isAwaitingFirstFix: Bool {
        settings.hasVisibleLiveLocationFields && viewModel.isSearching
    }

    /// Alanlar veya marka görünürse katman çizilir.
    private var shouldShowOverlay: Bool {
        !settings.enabledFields.isEmpty || branding != nil
    }

    private func statusCard(@ViewBuilder content: @escaping () -> some View) -> some View {
        GlassCardView {
            content()
                .font(.system(size: settings.textSize.pointSize))
                .fontDesign(settings.fontStyle.design)
        }
        .frame(width: maxWidth, alignment: .leading)
    }

    private var searchingRow: some View {
        HStack(spacing: LayoutConstants.Spacing.small) {
            ProgressView()
            Text("Konum aranıyor")
                .foregroundStyle(.secondary)
        }
    }

    private var permissionRow: some View {
        HStack(spacing: LayoutConstants.Spacing.small) {
            Label("Konum erişimi kapalı", systemImage: "location.slash")

            Spacer(minLength: LayoutConstants.Spacing.small)

            Button("Ayarlar", action: onOpenSettings)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    let dependencies = AppDependencies()
    return LocationStatusView(
        viewModel: dependencies.makeLocationViewModel(),
        settings: .default,
        branding: OverlayBranding(
            name: "GeoCam",
            logo: nil,
            symbolName: "camera.fill",
            accentColor: .yellow
        ),
        maxWidth: 320,
        onOpenSettings: {}
    )
    .padding()
}
