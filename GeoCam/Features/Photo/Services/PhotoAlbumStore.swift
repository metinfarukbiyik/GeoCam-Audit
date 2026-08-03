//
//  PhotoAlbumStore.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import OSLog
import Photos

/// Uygulamanın kendi albümünü çözer: varsa bulur, yoksa oluşturur.
/// Kimlik önbelleğe alınır, böylece her çekimde yeniden sorgu yapılmaz;
/// kullanıcı albümü silerse bir sonraki kayıtta yeniden üretilir.
@MainActor
final class PhotoAlbumStore {

    private let title: String
    private var cachedIdentifier: String?
    /// Sınırlı erişimde albüm oluşturulamaz; her çekimde boşuna denenmesin.
    private var creationFailed = false

    init(title: String = AppConstants.Info.photoAlbumName) {
        self.title = title
    }

    /// Albümün yerel kimliği. Erişim yetersizse `nil` döner; bu durumda çekim
    /// yine kitaplığa kaydedilir, yalnızca albüme eklenmez.
    func identifier() async -> String? {
        if let cachedIdentifier, Self.exists(cachedIdentifier) {
            return cachedIdentifier
        }

        if let existing = Self.firstCollection(titled: title)?.localIdentifier {
            cachedIdentifier = existing
            creationFailed = false
            return existing
        }

        guard !creationFailed else { return nil }

        cachedIdentifier = await create()
        creationFailed = cachedIdentifier == nil

        return cachedIdentifier
    }

    // MARK: - Private

    private func create() async -> String? {
        let title = title

        do {
            try await PHPhotoLibrary.shared().performChanges { @Sendable in
                _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: title)
            }
        } catch {
            AppLogger.photo.error("Albüm oluşturulamadı: \(error.localizedDescription, privacy: .public)")
            return nil
        }

        return Self.firstCollection(titled: title)?.localIdentifier
    }

    private nonisolated static func exists(_ identifier: String) -> Bool {
        PHAssetCollection
            .fetchAssetCollections(withLocalIdentifiers: [identifier], options: nil)
            .firstObject != nil
    }

    private nonisolated static func firstCollection(titled title: String) -> PHAssetCollection? {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "localizedTitle = %@", title)

        return PHAssetCollection
            .fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
            .firstObject
    }
}
