//
//  OverlayField.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Kullanıcının fotoğrafta gösterilmesini seçebileceği bilgi alanları.
nonisolated enum OverlayField: String, CaseIterable, Identifiable, Codable, Sendable {
    case date
    case time
    case address
    case coordinates
    case altitude
    case heading
    case accuracy
    case workOrder
    case siteID
    case jobSubject

    var id: String { rawValue }

    var title: String {
        switch self {
        case .date: "Tarih"
        case .time: "Saat"
        case .address: "Adres"
        case .coordinates: "Koordinatlar"
        case .altitude: "Rakım"
        case .heading: "Pusula Yönü"
        case .accuracy: "GPS Hassasiyeti"
        case .workOrder: "İş Emri"
        case .siteID: "Site ID"
        case .jobSubject: "Konu / Not"
        }
    }

    var systemImageName: String {
        switch self {
        case .date: "calendar"
        case .time: "clock"
        case .address: "mappin.and.ellipse"
        case .coordinates: "globe"
        case .altitude: "mountain.2"
        case .heading: "location.north.line"
        case .accuracy: "dot.radiowaves.left.and.right"
        case .workOrder: "doc.text"
        case .siteID: "building.2"
        case .jobSubject: "text.badge.plus"
        }
    }

    /// Konum sensörüne bağlı olmayan kurumsal iş alanları.
    var isJobInfoField: Bool {
        switch self {
        case .workOrder, .siteID, .jobSubject: true
        default: false
        }
    }
}
