//
//  CaptureThumbnailButton.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Son çekimi gösteren ve Fotoğraflar uygulamasına götüren küçük görsel.
struct CaptureThumbnailButton: View {

    let image: UIImage?
    let action: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: LayoutConstants.CornerRadius.small, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            content
                .frame(width: LayoutConstants.Thumbnail.size, height: LayoutConstants.Thumbnail.size)
                .clipShape(shape)
                .overlay {
                    shape.strokeBorder(.white.opacity(0.7), lineWidth: LayoutConstants.Thumbnail.borderWidth)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Fotoğraflar'ı aç")
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.white.opacity(0.15)

                Image(systemName: "photo.on.rectangle")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    HStack(spacing: LayoutConstants.Spacing.large) {
        CaptureThumbnailButton(image: nil, action: {})
    }
    .padding()
    .background(.black)
}
