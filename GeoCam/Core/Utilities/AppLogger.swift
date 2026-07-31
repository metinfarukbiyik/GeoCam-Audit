//
//  AppLogger.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import OSLog

/// Modül bazlı os.Logger örnekleri.
nonisolated enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? AppConstants.Info.appName

    static let camera = Logger(subsystem: subsystem, category: "Camera")
    static let location = Logger(subsystem: subsystem, category: "Location")
    static let photo = Logger(subsystem: subsystem, category: "Photo")
    static let settings = Logger(subsystem: subsystem, category: "Settings")
}
