//
//  DraggableOverlayPositioner.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Bilgi katmanını ekranın en soluna veya en sağına yaslar.
/// Yatayda ortaya alınamaz; dikeyde parmakla serbestçe taşınır.
/// Bırakınca kenar + dikey konum kaydedilir.
struct DraggableOverlayPositioner<Content: View>: View {

    let corner: OverlayCorner
    let verticalPosition: CGFloat
    /// Katmanın tamamına uygulanan geometrik ölçek.
    let scale: CGFloat
    let onPlacementChange: (_ corner: OverlayCorner, _ verticalPosition: CGFloat) -> Void
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
            let contentSize = CGSize(
                width: layoutWidth * currentScale,
                height: contentHeight * currentScale
            )
            let previewEdge = resolvedEdge(translation: dragTranslation, in: frameSize)
            let origin = previewOrigin(
                edge: previewEdge,
                contentSize: contentSize,
                in: frameSize
            )

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
                    .highPriorityGesture(dragGesture(contentSize: contentSize, in: frameSize))
                }
                .clipped()
                .onPreferenceChange(OverlayHeightKey.self) { contentHeight = $0 }
                .animation(
                    .easeInOut(duration: AppConstants.Animation.standard),
                    value: corner
                )
        }
    }

    private static func layoutWidth(in frameSize: CGSize) -> CGFloat {
        let isLandscape = frameSize.width > frameSize.height
        let ratio = isLandscape
            ? OverlayConstants.landscapeMaxWidthRatio
            : OverlayConstants.maxWidthRatio
        let width = max(frameSize.width * ratio, 0)

        guard isLandscape else { return width }

        return min(width, frameSize.height * OverlayConstants.landscapeShortSideWidthCap)
    }

    private var effectiveScale: CGFloat {
        guard isPinching else { return OverlayConstants.Scale.clamped(scale) }

        return OverlayConstants.Scale.clamped(scale * pinchMagnification)
    }

    /// İçerik genişliğinden bağımsız: sağa/sola eşiği aşınca kenar değişir.
    private func resolvedEdge(translation: CGSize, in frameSize: CGSize) -> OverlayCorner {
        guard !isPinching, translation != .zero else { return corner }

        let threshold = max(
            frameSize.width * OverlayDragConstants.edgeSwitchWidthRatio,
            OverlayDragConstants.edgeSwitchMinimumDistance
        )

        switch corner {
        case .leading:
            return translation.width > threshold ? .trailing : .leading
        case .trailing:
            return translation.width < -threshold ? .leading : .trailing
        }
    }

    private func previewOrigin(
        edge: OverlayCorner,
        contentSize: CGSize,
        in frameSize: CGSize
    ) -> CGPoint {
        let base = corner.origin(
            contentSize: contentSize,
            in: frameSize,
            verticalPosition: verticalPosition
        )
        guard !isPinching, dragTranslation != .zero else {
            return edge.origin(
                contentSize: contentSize,
                in: frameSize,
                verticalPosition: verticalPosition
            )
        }

        let range = OverlayCorner.verticalRange(contentHeight: contentSize.height, in: frameSize)
        let y = min(max(base.y + dragTranslation.height, range.lowerBound), range.upperBound)

        return edge.origin(
            contentSize: contentSize,
            in: frameSize,
            verticalPosition: OverlayCorner.normalizedVerticalPosition(
                y: y,
                contentHeight: contentSize.height,
                in: frameSize
            )
        )
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

                let translation = value.translation
                dragTranslation = translation
                let edge = resolvedEdge(translation: translation, in: frameSize)
                let base = corner.origin(
                    contentSize: contentSize,
                    in: frameSize,
                    verticalPosition: verticalPosition
                )
                let range = OverlayCorner.verticalRange(
                    contentHeight: contentSize.height,
                    in: frameSize
                )
                let y = min(max(base.y + translation.height, range.lowerBound), range.upperBound)
                let vertical = OverlayCorner.normalizedVerticalPosition(
                    y: y,
                    contentHeight: contentSize.height,
                    in: frameSize
                )

                if edge != corner || abs(vertical - OverlayConstants.VerticalPosition.clamped(verticalPosition)) > 0.001 {
                    onPlacementChange(edge, vertical)
                }
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

                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(50))
                    isPinching = false
                }
            }
    }
}

private enum OverlayDragConstants {
    /// Kenar değiştirmek için gereken yatay sürükleme oranı (ekran genişliğine göre).
    static let edgeSwitchWidthRatio: CGFloat = 0.16
    static let edgeSwitchMinimumDistance: CGFloat = 44
}

private struct OverlayHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    @Previewable @State var corner = OverlayCorner.trailing
    @Previewable @State var vertical: CGFloat = 0.7
    @Previewable @State var scale: CGFloat = 0.7

    return DraggableOverlayPositioner(
        corner: corner,
        verticalPosition: vertical,
        scale: scale,
        onPlacementChange: { corner = $0; vertical = $1 },
        onScaleChange: { scale = $0 }
    ) { maxWidth in
        Text("Besirli, Trabzon Merkez, Trabzon, Türkiye")
            .padding()
            .frame(width: maxWidth, alignment: .leading)
            .background(.gray.opacity(0.5))
    }
    .background(.black)
}
