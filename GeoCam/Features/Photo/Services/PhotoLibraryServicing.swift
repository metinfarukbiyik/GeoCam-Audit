//
//  PhotoLibraryServicing.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Fotoğraf kitaplığına kayıt işlemlerini soyutlar.
@MainActor
protocol PhotoLibraryServicing: AnyObject {
    var permissionStatus: PermissionStatus { get }

    func requestPermission() async -> PermissionStatus
    /// Görseli kitaplığa ve uygulama albümüne ekler.
    func save(imageData: Data) async throws
    /// Videoyu kitaplığa ekler ve geçici dosyayı temizler.
    func save(videoAt url: URL) async throws
}
