//
//  PhotoCaptureDelegate.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import OSLog

/// Tek bir fotoğraf çekimini async/await dünyasına köprüler.
/// Her çekim için yeni bir örnek oluşturulur ve sonuç bir kez iletilir.
nonisolated final class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {

    private let lock = NSLock()
    private var completion: (@Sendable (Result<Data, any Error>) -> Void)?

    init(completion: @escaping @Sendable (Result<Data, any Error>) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: (any Error)?
    ) {
        if let error {
            AppLogger.camera.error("Fotoğraf işlenemedi: \(error.localizedDescription, privacy: .public)")
            finish(with: .failure(CameraError.captureFailed))
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            finish(with: .failure(CameraError.captureFailed))
            return
        }

        finish(with: .success(data))
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
        error: (any Error)?
    ) {
        // Bu geri çağrı her zaman en son gelir. Veri üretilmişse no-op'tur;
        // üretilmemişse continuation'ın askıda kalmasını engeller.
        guard hasPendingCompletion else { return }

        AppLogger.camera.error("Çekim veri üretmeden sonlandı: \(error?.localizedDescription ?? "-", privacy: .public)")
        finish(with: .failure(CameraError.captureFailed))
    }

    private var hasPendingCompletion: Bool {
        lock.lock()
        defer { lock.unlock() }
        return completion != nil
    }

    private func finish(with result: Result<Data, any Error>) {
        lock.lock()
        let pending = completion
        completion = nil
        lock.unlock()

        pending?(result)
    }
}
