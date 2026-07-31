//
//  CameraFacing.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Aktif kameranın yönü.
nonisolated enum CameraFacing: String, CaseIterable, Identifiable, Sendable {
    case back
    case front

    var id: String { rawValue }

    var toggled: CameraFacing {
        self == .back ? .front : .back
    }
}
