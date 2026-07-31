//
//  CompassDirection.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// Manyetik yönün sekiz ana sektöre indirgenmiş hâli.
nonisolated enum CompassDirection: String, CaseIterable, Identifiable, Sendable {
    case north = "N"
    case northEast = "NE"
    case east = "E"
    case southEast = "SE"
    case south = "S"
    case southWest = "SW"
    case west = "W"
    case northWest = "NW"

    var id: String { rawValue }

    var abbreviation: String { rawValue }

    var localizedName: String {
        switch self {
        case .north: "Kuzey"
        case .northEast: "Kuzeydoğu"
        case .east: "Doğu"
        case .southEast: "Güneydoğu"
        case .south: "Güney"
        case .southWest: "Güneybatı"
        case .west: "Batı"
        case .northWest: "Kuzeybatı"
        }
    }

    /// 0-360° aralığındaki açıyı en yakın sektöre yuvarlar.
    init(degrees: CLLocationDirection) {
        let fullCircle = LocationConstants.Compass.degreesInCircle
        let sectorCount = LocationConstants.Compass.sectorCount
        let sectorSize = fullCircle / sectorCount

        let normalized = degrees.truncatingRemainder(dividingBy: fullCircle)
        let positive = normalized < 0 ? normalized + fullCircle : normalized
        let index = Int((positive + sectorSize / 2) / sectorSize) % Int(sectorCount)

        self = Self.allCases[index]
    }
}
