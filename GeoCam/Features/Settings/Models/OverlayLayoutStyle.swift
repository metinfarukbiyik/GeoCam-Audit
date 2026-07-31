//
//  OverlayLayoutStyle.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Bilgi katmanının seçilebilir yerleşim tasarımları.
nonisolated enum OverlayLayoutStyle: String, CaseIterable, Identifiable, Codable, Sendable {
    /// Simge + etiket + değer satırlarından oluşan klasik kart.
    case card
    /// Etiketsiz, tek paragraf detaylı dar kart.
    case compact
    /// Adresi başlık yapan, detayları iki sütuna dizen tam genişlik şerit.
    case banner
    /// Arka plansız, gölgeli düz metin.
    case minimal
    /// Altta gradient şerit; adres büyük, detaylar tek satır.
    case poster
    /// Etiket ve değerin iki sütunda hizalandığı teknik görünüm.
    case split
    /// Her alanın ayrı kapsül içinde gösterildiği yığılmış düzen.
    case capsule

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .card: language.t(.layoutCard)
        case .compact: language.t(.layoutCompact)
        case .banner: language.t(.layoutBanner)
        case .minimal: language.t(.layoutMinimal)
        case .poster: language.t(.layoutPoster)
        case .split: language.t(.layoutSplit)
        case .capsule: language.t(.layoutCapsule)
        }
    }
}
