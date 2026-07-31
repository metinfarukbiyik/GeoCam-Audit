//
//  LocationConstants.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// Konum ve pusula servisleri için sabitler.
nonisolated enum LocationConstants {

    enum Updates {
        /// Pil tüketimini sınırlamak için minimum konum değişim eşiği (metre).
        static let distanceFilter: CLLocationDistance = 5
        /// Pusula güncellemeleri için minimum açı değişimi (derece).
        static let headingFilter: CLLocationDegrees = 2
    }

    enum Accuracy {
        static let desired: CLLocationAccuracy = kCLLocationAccuracyBest
        /// Bu değerin altındaki yatay doğruluk yüksek kabul edilir (metre).
        static let highThreshold: CLLocationAccuracy = 10
        /// Bu değerin altındaki yatay doğruluk orta kabul edilir (metre).
        static let moderateThreshold: CLLocationAccuracy = 25
    }

    enum Geocoding {
        /// Aynı bölge için tekrarlanan reverse geocoding isteklerini engelleyen eşik (metre).
        static let minimumDistanceBetweenRequests: CLLocationDistance = 50
        /// Başarısız bir istekten sonra yeniden denemeden önce beklenecek süre.
        static let retryCooldown: TimeInterval = 30
    }

    enum Compass {
        static let degreesInCircle: Double = 360
        static let sectorCount: Double = 8
    }
}
