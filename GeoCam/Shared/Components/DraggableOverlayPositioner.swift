//
//  DraggableOverlayPositioner.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Bilgi katmanını ekran içinde tutar: sabit genişlik, sürükleme, pinch ile punto.
struct DraggableOverlayPositioner<Content: View>: View {

    let position: OverlayPosition
    let textSize: OverlayTextSize
    let onPositionChange: (OverlayPosition) -> Void
    let onTextSizeChange: (OverlayTextSize) -> Void
    @ViewBuilder let content: (_ maxWidth: CGFloat) -> Content

    @State private var contentHeight: CGFloat = 120
    @State private var dragTranslation: CGSize = .zero
    @State private var pinchScale: CGFloat = 1
    @State private var lastPinchMagnification: CGFloat = 1
    @State private var isPinching = false

    var body: some View {
        GeometryReader { proxy in
            let frameSize = proxy.size
            let horizontalInset = frameSize.width * OverlayConstants.horizontalInsetRatio
            let boxWidth = max(frameSize.width - horizontalInset * 2, 0)
            let contentSize = CGSize(width: boxWidth, height: contentHeight)
            let origin = resolvedPosition(contentSize: contentSize, in: frameSize)
                .origin(in: frameSize)

            Color.clear
                .frame(width: frameSize.width, height: frameSize.height)
                .overlay(alignment: .topLeading) {
                    FixedWidthLayout(width: boxWidth) {
                        content(boxWidth)
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
                    .scaleEffect(pinchScale, anchor: .topLeading)
                    .offset(x: origin.x, y: origin.y)
                    .gesture(pinchGesture)
                    .simultaneousGesture(dragGesture(contentSize: contentSize, in: frameSize))
                }
                .clipped()
                .onPreferenceChange(OverlayHeightKey.self) { contentHeight = $0 }
                .onAppear {
                    reclampIfNeeded(contentSize: contentSize, in: frameSize)
                }
                .onChange(of: contentHeight) { _, height in
                    reclampIfNeeded(
                        contentSize: CGSize(width: boxWidth, height: height),
                        in: frameSize
                    )
                }
                .onChange(of: position) { _, newPosition in
                    reclampIfNeeded(
                        position: newPosition,
                        contentSize: contentSize,
                        in: frameSize
                    )
                }
                .onChange(of: textSize) { _, _ in
                    let leading = OverlayPosition(
                        x: OverlayConstants.horizontalInsetRatio,
                        y: position.y
                    ).clamped(contentSize: contentSize, in: frameSize)

                    if leading != position {
                        onPositionChange(leading)
                    }
                }
        }
    }

    private func resolvedPosition(contentSize: CGSize, in frameSize: CGSize) -> OverlayPosition {
        guard !isPinching else {
            return position.clamped(contentSize: contentSize, in: frameSize)
        }

        return position
            .moved(by: dragTranslation, in: frameSize)
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

                onPositionChange(
                    position
                        .moved(by: value.translation, in: frameSize)
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

                lastPinchMagnification = value
                pinchScale = min(max(value, 0.7), 1.35)
            }
            .onEnded { _ in
                let magnification = lastPinchMagnification
                pinchScale = 1
                lastPinchMagnification = 1
                dragTranslation = .zero

                if magnification <= OverlayConstants.Pinch.shrinkThreshold, let smaller = textSize.smaller {
                    onTextSizeChange(smaller)
                } else if magnification >= OverlayConstants.Pinch.growThreshold, let larger = textSize.larger {
                    onTextSizeChange(larger)
                }

                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(50))
                    isPinching = false
                }
            }
    }

    private func reclampIfNeeded(
        position: OverlayPosition? = nil,
        contentSize: CGSize,
        in frameSize: CGSize
    ) {
        guard contentSize.width > 0, frameSize.width > 0 else { return }

        let source = position ?? self.position
        let clamped = source.clamped(contentSize: contentSize, in: frameSize)
        guard clamped != source else { return }
        onPositionChange(clamped)
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
    @Previewable @State var textSize = OverlayTextSize.medium

    return DraggableOverlayPositioner(
        position: position,
        textSize: textSize,
        onPositionChange: { position = $0 },
        onTextSizeChange: { textSize = $0 }
    ) { maxWidth in
        Text("Besirli, Trabzon Merkez, Trabzon, Türkiye")
            .padding()
            .frame(width: maxWidth, alignment: .leading)
            .background(.gray.opacity(0.5))
    }
    .background(.black)
}
