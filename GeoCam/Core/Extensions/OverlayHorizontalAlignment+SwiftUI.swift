//
//  OverlayHorizontalAlignment+SwiftUI.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import SwiftUI

/// Katman yaslamasının SwiftUI karşılıkları.
/// Tasarımlar bu değerleri kullanır; yön mantığı tek yerde tutulur.
nonisolated extension OverlayHorizontalAlignment {

    var opposite: OverlayHorizontalAlignment {
        switch self {
        case .leading: .trailing
        case .trailing: .leading
        }
    }

    var stackAlignment: HorizontalAlignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var frameAlignment: Alignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }

    var textAlignment: TextAlignment {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}
