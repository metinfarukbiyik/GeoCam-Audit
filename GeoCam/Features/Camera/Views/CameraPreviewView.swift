//
//  CameraPreviewView.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import SwiftUI

/// AVCaptureVideoPreviewLayer'ı SwiftUI hiyerarşisine taşır.
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer

    func makeUIView(context: Context) -> PreviewContainerView {
        PreviewContainerView(previewLayer: previewLayer)
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {}

    /// Preview layer'ı barındıran ve boyutunu görünümle eşitleyen UIView.
    final class PreviewContainerView: UIView {
        private let previewLayer: AVCaptureVideoPreviewLayer

        init(previewLayer: AVCaptureVideoPreviewLayer) {
            self.previewLayer = previewLayer
            super.init(frame: .zero)
            backgroundColor = .black
            layer.addSublayer(previewLayer)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) desteklenmiyor.")
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // Katman boyutu değişiminde istenmeyen animasyonu engeller.
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            previewLayer.frame = bounds
            CATransaction.commit()
        }
    }
}
