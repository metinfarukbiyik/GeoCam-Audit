//
//  CameraZoomPicker.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// 0.5× / 1× / 2× yakınlaştırma basamaklarını seçtiren kontrol.
struct CameraZoomPicker: View {
    let selection: CameraZoomFactor
    let availableFactors: [CameraZoomFactor]
    let onSelect: (CameraZoomFactor) -> Void

    var body: some View {
        HStack(spacing: LayoutConstants.ZoomControl.spacing) {
            ForEach(availableFactors) { factor in
                Button {
                    onSelect(factor)
                } label: {
                    Text(factor == selection ? factor.selectedTitle : factor.title)
                        .font(.caption.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(factor == selection ? .yellow : .white)
                        .frame(
                            width: LayoutConstants.ZoomControl.buttonDiameter,
                            height: LayoutConstants.ZoomControl.buttonDiameter
                        )
                        .background(Circle().fill(.black.opacity(0.45)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(factor.selectedTitle) yakınlaştırma")
                .accessibilityAddTraits(factor == selection ? .isSelected : [])
            }
        }
    }
}

#Preview {
    CameraZoomPicker(
        selection: .wide,
        availableFactors: CameraZoomFactor.allCases,
        onSelect: { _ in }
    )
    .padding()
    .background(.gray)
}
