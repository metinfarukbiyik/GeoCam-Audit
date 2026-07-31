//
//  FileManager+Removal.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

nonisolated extension FileManager {

    /// Dosya yoksa hata üretmeden geçer; geçici dosya temizliğinde kullanılır.
    func removeItemIfExists(at url: URL) throws {
        guard fileExists(atPath: url.path) else { return }

        try removeItem(at: url)
    }
}
