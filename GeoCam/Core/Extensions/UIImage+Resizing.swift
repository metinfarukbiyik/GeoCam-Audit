//
//  UIImage+Resizing.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

nonisolated extension UIImage {

    /// Uzun kenarı verilen sınıra indirir. Kullanıcının seçtiği logoyu saklanabilir boyutta tutar.
    func downscaled(toMaxDimension limit: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)

        guard longestSide > limit, longestSide > 0 else { return self }

        let ratio = limit / longestSide
        let targetSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
