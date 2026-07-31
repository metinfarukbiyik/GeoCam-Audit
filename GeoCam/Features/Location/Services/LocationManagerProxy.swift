//
//  LocationManagerProxy.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// CLLocationManager delegate geri çağrılarını sıralı bir olay akışına dönüştürür.
/// Böylece servisler ana aktörde, delegate izolasyonuyla uğraşmadan çalışabilir.
nonisolated final class LocationManagerProxy: NSObject, CLLocationManagerDelegate, @unchecked Sendable {

    enum Event: Sendable {
        case authorization(PermissionStatus)
        case location(LocationSnapshot)
        case heading(CompassReading)
        case failure(LocationError)
    }

    let events: AsyncStream<Event>

    private let continuation: AsyncStream<Event>.Continuation

    override init() {
        (events, continuation) = AsyncStream.makeStream(bufferingPolicy: .bufferingNewest(Self.bufferSize))
        super.init()
    }

    deinit {
        continuation.finish()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        continuation.yield(.authorization(PermissionStatus(manager.authorizationStatus)))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, let snapshot = LocationSnapshot(location) else { return }

        continuation.yield(.location(snapshot))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard let reading = CompassReading(newHeading) else { return }

        continuation.yield(.heading(reading))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        guard let clError = error as? CLError else {
            continuation.yield(.failure(.locationUnavailable))
            return
        }

        switch clError.code {
        case .denied: continuation.yield(.failure(.permissionDenied))
        default: continuation.yield(.failure(.locationUnavailable))
        }
    }

    private static let bufferSize = 16
}
