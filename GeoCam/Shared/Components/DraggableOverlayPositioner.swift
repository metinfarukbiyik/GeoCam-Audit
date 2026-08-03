//
//  DraggableOverlayPositioner.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Bilgi katmanını çerçeve içinde konumlandırır: kenar yaslaması, sürükleme ve
/// çift parmakla tüm tasarımı küçültme.
/// Kayıtlı konum yalnızca kullanıcı sürüklediğinde güncellenir; yerleşim kaynaklı
/// sığdırma işlemleri sadece görüntülemeye uygulanır.
struct DraggableOverlayPositioner<Content: View>: View {

    let position: OverlayPosition
    let alignment: OverlayHorizontalAlignment
    /// Katmanın tamamına uygulanan geometrik ölçek.
    let scale: CGFloat
    let onPositionChange: (OverlayPosition) -> Void
    let onScaleChange: (CGFloat) -> Void
    @ViewBuilder let content: (_ maxWidth: CGFloat) -> Content

    @State private var contentHeight: CGFloat = 120
    @State private var dragTranslation: CGSize = .zero
    @State private var pinchMagnification: CGFloat = 1
    @State private var isPinching = false

    var body: some View {
        GeometryReader { proxy in
            let frameSize = proxy.size
            let layoutWidth = Self.layoutWidth(in: frameSize)
            let currentScale = effectiveScale
            // Tasarım tam genişlikte çizilip küçültülür; satır kırılmaları damgayla aynı kalır.
            let contentSize = CGSize(
                width: layoutWidth * currentScale,
                height: contentHeight * currentScale
            )
            let origin = resolvedPosition(contentSize: contentSize, in: frameSize)
                .origin(contentSize: contentSize, in: frameSize, alignment: alignment)

            Color.clear
                .frame(width: frameSize.width, height: frameSize.height)
                .overlay(alignment: .topLeading) {
                    FixedWidthLayout(width: layoutWidth) {
                        content(layoutWidth)
                    }
                    .background {
                        GeometryReader { inner in
                            Color.clear.preference(
                                key: OverlayHeightKey.self,
                                value: inner.size.height
                            )
                        }
                    }
                    .compositingGroup()
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .scaleEffect(currentScale, anchor: .topLeading)
                    .offset(x: origin.x, y: origin.y)
                    .gesture(pinchGesture)
                    .simultaneousGesture(dragGesture(contentSize: contentSize, in: frameSize))
                }
                .clipped()
                .onPreferenceChange(OverlayHeightKey.self) { contentHeight = $0 }
        }
    }

    /// Tasarımın çizildiği mantıksal genişlik; yatayda kısa kenarı yutmaz.
    private static func layoutWidth(in frameSize: CGSize) -> CGFloat {
        let isLandscape = frameSize.width > frameSize.height
        let ratio = isLandscape
            ? OverlayConstants.landscapeMaxWidthRatio
            : OverlayConstants.maxWidthRatio
        let width = max(frameSize.width * ratio, 0)

        guard isLandscape else { return width }

        return min(width, frameSize.height * OverlayConstants.landscapeShortSideWidthCap)
    }

    /// Pinch sırasında önizleme, jest bittiğinde uygulanacak ölçeği birebir yansıtır.
    private var effectiveScale: CGFloat {
        guard isPinching else { return OverlayConstants.Scale.clamped(scale) }

        return OverlayConstants.Scale.clamped(scale * pinchMagnification)
    }

    private func resolvedPosition(contentSize: CGSize, in frameSize: CGSize) -> OverlayPosition {
        let base = position.clamped(contentSize: contentSize, in: frameSize)
        guard !isPinching else { return base }

        return base
            .moved(by: dragTranslation, in: frameSize, alignment: alignment)
            .clamped(contentSize: contentSize, in: frameSize)
    }

    private func dragGesture(contentSize: CGSize, in frameSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard !isPinching else { return }
                dragTranslation = value.translation
            }
            .onEnded { value in
                defer { dragTranslation = .zero }
                guard !isPinching else { return }

                // Sürükleme, ekranda görünen konumdan devam eder.
                let base = position.clamped(contentSize: contentSize, in: frameSize)
                onPositionChange(
                    base
                        .moved(by: value.translation, in: frameSize, alignment: alignment)
                        .clamped(contentSize: contentSize, in: frameSize)
                )
            }
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isPinching {
                    isPinching = true
                    dragTranslation = .zero
                }

                pinchMagnification = value
            }
            .onEnded { value in
                let resolved = OverlayConstants.Scale.clamped(scale * value)
                pinchMagnification = 1
                dragTranslation = .zero

                if resolved != OverlayConstants.Scale.clamped(scale) {
                    onScaleChange(resolved)
                }

                // Jest biter bitmez sürükleme devralmasın diye kısa bir tampon bırakılır.
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(50))
                    isPinching = false
                }
            }
    }
}

private struct OverlayHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    @Previewable @State var position = OverlayPosition.default
    @Previewable @State var scale: CGFloat = 0.7

    return DraggableOverlayPositioner(
        position: position,
        alignment: .trailing,
        scale: scale,
        onPositionChange: { position = $0 },
        onScaleChange: { scale = $0 }
    ) { maxWidth in
        Text("Besirli, Trabzon Merkez, Trabzon, Türkiye")
            .padding()
            .frame(width: maxWidth, alignment: .leading)
            .background(.gray.opacity(0.5))
    }
    .background(.black)
}
