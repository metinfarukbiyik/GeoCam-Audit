//
//  PostalAddress.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Reverse geocoding sonucundan üretilen açık adres.
nonisolated struct PostalAddress: Equatable, Sendable {
    let neighborhood: String?
    let district: String?
    let city: String?
    let country: String?

    /// "Mahalle, İlçe, İl, Ülke" biçiminde metin. Hiçbir bileşen yoksa nil döner.
    var formatted: String? {
        let components = [neighborhood, district, city, country].compactMap(\.self)

        // Bazı bölgelerde ilçe ve il aynı isimle döner; tekrarı gizlemek gerekir.
        var uniqueComponents: [String] = []
        for component in components where !uniqueComponents.contains(component) {
            uniqueComponents.append(component)
        }

        return uniqueComponents.isEmpty ? nil : uniqueComponents.joined(separator: ", ")
    }
}
