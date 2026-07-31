//
//  BrandIcon.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Marka adının önünde gösterilebilecek SF Symbol seçenekleri.
nonisolated enum BrandIcon: String, CaseIterable, Identifiable, Codable, Sendable {
    case none
    case building
    case hammer
    case wrench
    case house
    case map
    case camera
    case seal
    case star
    case briefcase
    case gear
    case leaf
    case bolt
    case shield
    case location
    case checkmark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "Yok"
        case .building: "Bina"
        case .hammer: "Çekiç"
        case .wrench: "Tamir"
        case .house: "Ev"
        case .map: "Harita"
        case .camera: "Kamera"
        case .seal: "Onay"
        case .star: "Yıldız"
        case .briefcase: "Çanta"
        case .gear: "Dişli"
        case .leaf: "Yaprak"
        case .bolt: "Şimşek"
        case .shield: "Kalkan"
        case .location: "Konum"
        case .checkmark: "Tik"
        }
    }

    /// SF Symbol adı; `none` için nil.
    var systemImageName: String? {
        switch self {
        case .none: nil
        case .building: "building.2.fill"
        case .hammer: "hammer.fill"
        case .wrench: "wrench.and.screwdriver.fill"
        case .house: "house.fill"
        case .map: "map.fill"
        case .camera: "camera.fill"
        case .seal: "checkmark.seal.fill"
        case .star: "star.fill"
        case .briefcase: "briefcase.fill"
        case .gear: "gearshape.fill"
        case .leaf: "leaf.fill"
        case .bolt: "bolt.fill"
        case .shield: "shield.fill"
        case .location: "mappin.and.ellipse"
        case .checkmark: "checkmark.circle.fill"
        }
    }
}
