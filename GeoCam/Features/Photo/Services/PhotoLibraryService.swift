//
//  PhotoLibraryService.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import OSLog
import Photos

/// PhotoKit tabanlı kayıt servisi.
/// Çekimler hem kitaplığa hem de uygulamanın kendi albümüne yazılır.
@MainActor
@Observable
final class PhotoLibraryService: PhotoLibraryServicing {

    /// Albümü bulup oluşturabilmek için salt ekleme yetkisi yetmez, okuma da gerekir.
    private static let accessLevel: PHAccessLevel = .readWrite

    private(set) var permissionStatus: PermissionStatus

    private let albumStore = PhotoAlbumStore()

    init() {
        permissionStatus = PermissionStatus(PHPhotoLibrary.authorizationStatus(for: Self.accessLevel))
    }

    func requestPermission() async -> PermissionStatus {
        let current = PermissionStatus(PHPhotoLibrary.authorizationStatus(for: Self.accessLevel))
        guard current == .notDetermined else {
            permissionStatus = current
            return current
        }

        let status = await PHPhotoLibrary.requestAuthorization(for: Self.accessLevel)
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
        guard await requestPermission().isAuthorized else {
            throw PhotoError.libraryPermissionDenied
        }

        let albumIdentifier = await albumStore.identifier()

        do {
            try await PHPhotoLibrary.shared().performChanges { @Sendable in
                let request = PHAssetCreationRequest.forAsset()
                configure(request)
                Self.addCreatedAsset(of: request, toAlbum: albumIdentifier)
            }
        } catch {
            AppLogger.photo.error("Kitaplığa kaydedilemedi: \(error.localizedDescription, privacy: .public)")
            throw PhotoError.saveFailed
        }
    }

    /// Albüme ekleme sessizce atlanabilir; çekimin kitaplığa yazılması her koşulda önceliklidir.
    private nonisolated static func addCreatedAsset(
        of request: PHAssetCreationRequest,
        toAlbum identifier: String?
    ) {
        guard let identifier,
              let placeholder = request.placeholderForCreatedAsset,
              let album = PHAssetCollection
                  .fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil)
                  .firstObject,
              let albumRequest = PHAssetCollectionChangeRequest(for: album)
        else { return }

        albumRequest.addAssets([placeholder] as NSArray)
    }
}
