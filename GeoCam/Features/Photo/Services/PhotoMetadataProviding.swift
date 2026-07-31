//
//  PhotoMetadataProviding.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Çekim anındaki bilgi katmanı verisini üretir.
@MainActor
protocol PhotoMetadataProviding: AnyObject {
    func currentMetadata() -> PhotoMetadata
}
