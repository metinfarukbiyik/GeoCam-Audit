//
//  PhotoLibraryService.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import OSLog
import Photos

/// PhotoKit tabanlı kayıt servisi.
@MainActor
@Observable
final class PhotoLibraryService: PhotoLibraryServicing {

    private(set) var permissionStatus: PermissionStatus

    init() {
        permissionStatus = PermissionStatus(PHPhotoLibrary.authorizationStatus(for: .addOnly))
    }

    func requestAddPermission() async -> PermissionStatus {
        let current = PermissionStatus(PHPhotoLibrary.authorizationStatus(for: .addOnly))
        guard current == .notDetermined else {
            permissionStatus = current
            return current
        }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        permissionStatus = PermissionStatus(status)
        return permissionStatus
    }

    func save(imageData: Data) async throws {
        try await performCreation { request in
            request.addResource(with: .photo, data: imageData, options: nil)
        }
    }

    func save(videoAt url: URL) async throws {
        defer { try? FileManager.default.removeItemIfExists(at: url) }

        try await performCreation { request in
            // Seçenek nesnesi Sendable olmadığı için blok içinde üretilir.
            let options = PHAssetResourceCreationOptions()
            options.shouldMoveFile = true

            request.addResource(with: .video, fileURL: url, options: options)
        }
    }

    // MARK: - Private

    /// PhotoKit bu bloğu kendi arka plan kuyruğunda çalıştırır. @Sendable olmazsa blok
    /// çevresindeki MainActor izolasyonunu miras alır ve çalışma anında trap üretir.
    private func performCreation(
        _ configure: @escaping @Sendable (PHAssetCreationRequest) -> Void
    ) async throws {
        guard await requestAddPermission().isAuthorized else {
            throw PhotoError.libraryPermissionDenied
        }

        do {
            try await PHPhotoLibrary.shared().performChanges { @Sendable in
                configure(PHAssetCreationRequest.forAsset())
            }
        } catch {
            AppLogger.photo.error("Kitaplığa kaydedilemedi: \(error.localizedDescription, privacy: .public)")
            throw PhotoError.saveFailed
        }
    }
}
