//
//  CameraConstants.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Capture session ve fotoğraf çıktısı ile ilgili sabitler.
nonisolated enum CameraConstants {

    enum Session {
        static let queueLabel = "com.geocam.camera.session"
    }

    enum Output {
        static let jpegCompressionQuality: Double = 0.95
    }

    /// Seri çekimde arka plan damga/kayıt kuyruğu sınırları.
    enum Capture {
        /// Aynı anda kaç fotoğrafın damga+kayıt işlemi yürüsün.
        static let maxConcurrentProcessing = 1
        /// Deklanşörün kabul edeceği en fazla bekleyen iş (işlenenler dahil).
        static let maxPendingJobs = 5
    }

    enum Video {
        static let fileExtension = "mov"
        /// Tek bir kaydın üst sınırı; dolan diski ve kazara uzun kayıtları engeller.
        static let maximumDuration: TimeInterval = 10 * 60
    }

    enum Recovery {
        /// Oturum çalışma zamanı hatasından sonra yeniden başlatma denemesi sayısı.
        static let maxRestartAttempts = 3
        /// Denemeler arasında beklenecek süre.
        static let restartDelay: Duration = .milliseconds(400)
    }

    enum Zoom {
        /// Zoom geçiş animasyonunun süresi.
        static let rampDuration: Double = 0.18
        /// Ultra geniş (0.5x) için sanal cihazdaki tipik taban faktör.
        static let ultraWideDeviceFactor: CGFloat = 1
    }
}
