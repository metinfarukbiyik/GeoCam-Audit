//
//  SettingsStoring.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Kullanıcı tercihlerinin kalıcılığını soyutlar.
@MainActor
protocol SettingsStoring: AnyObject {
    var settings: OverlaySettings { get }

    func update(_ settings: OverlaySettings)
    func resetToDefaults()
}
