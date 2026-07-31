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

    func title(language: AppLanguage) -> String {
        switch self {
        case .date: language.t(.fieldDate)
        case .time: language.t(.fieldTime)
        case .address: language.t(.fieldAddress)
        case .coordinates: language.t(.fieldCoordinates)
        case .altitude: language.t(.fieldAltitude)
        case .heading: language.t(.fieldHeading)
        case .accuracy: language.t(.fieldAccuracy)
        case .workOrder: language.t(.fieldWorkOrder)
        case .siteID: language.t(.fieldSiteID)
        case .jobSubject: language.t(.fieldJobSubject)
        }
    }

    func shortTitle(language: AppLanguage) -> String {
        switch self {
        case .date: language.t(.fieldDate)
        case .time: language.t(.fieldTime)
        case .address: language.t(.fieldShortLocation)
        case .coordinates: language.t(.fieldShortCoordinate)
        case .altitude: language.t(.fieldShortAltitude)
        case .heading: language.t(.fieldShortHeading)
        case .accuracy: language.t(.fieldShortGPS)
        case .workOrder: language.t(.prefixWorkOrder)
        case .siteID: language.t(.prefixSite)
        case .jobSubject: language.t(.prefixNote)
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
