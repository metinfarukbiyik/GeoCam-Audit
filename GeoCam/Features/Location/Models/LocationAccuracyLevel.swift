//
//  LocationAccuracyLevel.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// GPS doğruluğunun kullanıcıya sunulan kalite seviyesi.
nonisolated enum LocationAccuracyLevel: Sendable {
    case high
    case moderate
    case low

    init(horizontalAccuracy: CLLocationAccuracy) {
        switch horizontalAccuracy {
        case ..<LocationConstants.Accuracy.highThreshold: self = .high
        case ..<LocationConstants.Accuracy.moderateThreshold: self = .moderate
        default: self = .low
        }
    }

    var systemImageName: String {
        switch self {
        case .high: "dot.radiowaves.left.and.right"
        case .moderate: "wave.3.right"
        case .low: "exclamationmark.triangle"
        }
    }
}
