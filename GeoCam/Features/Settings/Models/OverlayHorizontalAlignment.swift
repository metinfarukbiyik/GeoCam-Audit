//
//  OverlayHorizontalAlignment.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

/// Bilgi katmanının hangi kenara yaslandığı.
/// Konum ölçüsü (`OverlayPosition.x`) yaslanan kenardan içeri boşluk olarak yorumlanır.
nonisolated enum OverlayHorizontalAlignment: String, CaseIterable, Identifiable, Codable, Sendable {
    case leading
    case trailing

    var id: String { rawValue }

    func title(language: AppLanguage) -> String {
        switch self {
        case .leading: language.t(.alignmentLeading)
        case .trailing: language.t(.alignmentTrailing)
        }
    }
}
