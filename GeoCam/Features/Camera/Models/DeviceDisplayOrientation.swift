//
//  DeviceDisplayOrientation.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import UIKit

/// Arayüz kilidine bakılmaksızın cihazın fiziksel yönü (yerçekimine göre).
nonisolated enum DeviceDisplayOrientation: Equatable, Sendable {
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight

    /// UIDevice yönünden üretir; belirsiz durumlarda `nil` döner.
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            return nil
        }
    }

    var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight:
            true
        case .portrait, .portraitUpsideDown:
            false
        }
    }

    /// Portre kilitliyken katmanı yerçekimine hizalamak için dönüş açısı (saat yönü pozitif).
    var gravityAlignmentDegrees: Double {
        switch self {
        case .portrait:
            0
        case .landscapeLeft:
            // Fiziksel üst, portre UI'ın sol kenarıdır.
            -90
        case .landscapeRight:
            90
        case .portraitUpsideDown:
            180
        }
    }
}
