//
//  CameraFlashMode.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Kullanıcının seçebileceği flaş modları.
nonisolated enum CameraFlashMode: String, CaseIterable, Identifiable, Sendable {
    case auto
    case on
    case off

    var id: String { rawValue }

    var systemImageName: String {
        switch self {
        case .auto: "bolt.badge.a.fill"
        case .on: "bolt.fill"
        case .off: "bolt.slash.fill"
        }
    }

    /// Modlar arasında döngüsel geçiş sağlar.
    var next: CameraFlashMode {
        switch self {
        case .auto: .on
        case .on: .off
        case .off: .auto
        }
    }
}
