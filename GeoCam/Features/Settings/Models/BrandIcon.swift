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

    func title(language: AppLanguage) -> String {
        switch self {
        case .none: language.t(.brandIconNone)
        case .building: language.t(.brandIconBuilding)
        case .hammer: language.t(.brandIconHammer)
        case .wrench: language.t(.brandIconWrench)
        case .house: language.t(.brandIconHouse)
        case .map: language.t(.brandIconMap)
        case .camera: language.t(.brandIconCamera)
        case .seal: language.t(.brandIconSeal)
        case .star: language.t(.brandIconStar)
        case .briefcase: language.t(.brandIconBriefcase)
        case .gear: language.t(.brandIconGear)
        case .leaf: language.t(.brandIconLeaf)
        case .bolt: language.t(.brandIconBolt)
        case .shield: language.t(.brandIconShield)
        case .location: language.t(.brandIconLocation)
        case .checkmark: language.t(.brandIconCheckmark)
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
