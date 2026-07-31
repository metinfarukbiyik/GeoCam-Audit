//
//  PhotoMetadata.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Fotoğraf üzerine basılacak bilgi katmanının veri kaynağı.
nonisolated struct PhotoMetadata: Equatable, Sendable {
    let capturedAt: Date
    let location: LocationSnapshot?
    let compassReading: CompassReading?
    let address: PostalAddress?
}
