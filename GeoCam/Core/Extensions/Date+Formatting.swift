//
//  Date+Formatting.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

nonisolated extension Date {

    /// Sabit gün/ay/yıl biçimi (örn. 30/07/2026).
    var overlayDateText: String {
        Self.overlayDateFormatter.string(from: self)
    }

    /// 24 saat diliminde kısa saat (örn. 18:30).
    var overlayTimeText: String {
        Self.overlayTimeFormatter.string(from: self)
    }

    private static let overlayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    private static let overlayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
