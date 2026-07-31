//
//  CameraManaging.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import AVFoundation

/// Capture session yaşam döngüsünü, fotoğraf çekimini ve video kaydını soyutlar.
/// Test ve preview'larda sahte uygulamalarla değiştirilebilir.
@MainActor
protocol CameraManaging: AnyObject {
    /// Canlı görüntünün sunulduğu katman.
    var previewLayer: AVCaptureVideoPreviewLayer { get }
    var permissionStatus: PermissionStatus { get }
    var isSessionRunning: Bool { get }
    var isRecording: Bool { get }
    var configuration: CameraConfiguration { get }
    var zoomFactor: CameraZoomFactor { get }
    var availableZoomFactors: [CameraZoomFactor] { get }
    /// Pinch için cihazın güncel videoZoomFactor değeri.
    var deviceZoomFactor: CGFloat { get }

    func requestPermission() async -> PermissionStatus
    func prepareSession() async throws
    func startSession() async
    func stopSession() async
    func setFlashMode(_ flashMode: CameraFlashMode)
    func setCaptureMode(_ mode: CaptureMode) async throws
    func switchCamera() async throws
    func setZoomFactor(_ factor: CameraZoomFactor) async
    /// Çift parmak sıkıştırma ile sürekli zoom.
    func setDeviceZoomFactor(_ factor: CGFloat) async
    /// Pinch bitince en yakın 0.5 / 1 / 2 basamağına oturtur.
    func snapZoomToNearestFactor() async
    /// Çekilen fotoğrafın ham verisini (EXIF dahil) döndürür.
    func capturePhoto() async throws -> Data
    func startRecording() async throws
    /// Kaydı bitirir ve geçici dosyanın konumunu döndürür.
    func stopRecording() async throws -> URL
}
