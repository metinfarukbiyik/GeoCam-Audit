//
//  UIImage+Orientation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

nonisolated extension UIImage {

    /// EXIF yönünü piksel verisine işleyerek dik duran bir görüntü üretir.
    /// UIGraphicsImageRenderer thread-safe olduğu için arka planda çağrılabilir.
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
