//
//  BrandingAssetStoring.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

/// Şirket logosunun kalıcı olarak saklanmasını soyutlar.
@MainActor
protocol BrandingAssetStoring: AnyObject {
    var logo: UIImage? { get }

    func updateLogo(_ image: UIImage?)
}
