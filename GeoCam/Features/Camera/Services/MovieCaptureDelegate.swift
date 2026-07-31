//
//  MovieCaptureDelegate.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation
import OSLog

/// Tek bir video kaydını async/await dünyasına köprüler.
nonisolated final class MovieCaptureDelegate: NSObject, AVCaptureFileOutputRecordingDelegate, @unchecked Sendable {

    private let lock = NSLock()
    private var completion: (@Sendable (Result<URL, any Error>) -> Void)?

    init(completion: @escaping @Sendable (Result<URL, any Error>) -> Void) {
        self.completion = completion
    }

    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: (any Error)?
    ) {
        lock.lock()
        let pending = completion
        completion = nil
        lock.unlock()

        guard let pending else { return }

        // AVFoundation, kayıt kullanılabilir haldeyken de hata bildirebilir;
        // bu durumda dosya geçerlidir ve atılmamalıdır.
        if let error, !Self.isRecoverable(error) {
            AppLogger.camera.error("Video kaydedilemedi: \(error.localizedDescription, privacy: .public)")
            pending(.failure(CameraError.recordingFailed))
            return
        }

        pending(.success(outputFileURL))
    }

    private static func isRecoverable(_ error: any Error) -> Bool {
        let info = (error as NSError).userInfo

        return info[AVErrorRecordingSuccessfullyFinishedKey] as? Bool == true
    }
}
