//
//  UIImage+Cropping.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

nonisolated extension UIImage {

    /// Görüntüyü verilen genişlik/yükseklik oranına ortalayarak kırpar.
    /// Yönün piksel verisine işlenmiş olması beklenir.
    func cropped(toAspectRatio ratio: CGFloat) -> UIImage {
        guard let cgImage, ratio > 0 else { return self }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        guard width > 0, height > 0, abs(width / height - ratio) > .ulpOfOne else { return self }

        let targetSize = width / height > ratio
            ? CGSize(width: height * ratio, height: height)
            : CGSize(width: width, height: width / ratio)

        let origin = CGPoint(
            x: (width - targetSize.width) / 2,
            y: (height - targetSize.height) / 2
        )

        guard let cropped = cgImage.cropping(to: CGRect(origin: origin, size: targetSize).integral) else {
            return self
        }

        return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation)
    }
}
