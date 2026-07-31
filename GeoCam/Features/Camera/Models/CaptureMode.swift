//
//  CaptureMode.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Deklanşörün fotoğraf mı yoksa video mu ürettiğini belirler.
nonisolated enum CaptureMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case photo
    case video

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photo: "Fotoğraf"
        case .video: "Video"
        }
    }

    var systemImageName: String {
        switch self {
        case .photo: "camera.fill"
        case .video: "video.fill"
        }
    }
}
