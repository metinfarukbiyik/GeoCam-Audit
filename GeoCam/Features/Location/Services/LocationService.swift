//
//  LocationService.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// CoreLocation tabanlı konum servisi.
/// Güncellemeler yalnızca bir kez başlatılır; ekran değişimlerinde yeniden kurulmaz.
@MainActor
@Observable
final class LocationService: LocationServicing {

    private(set) var permissionStatus: PermissionStatus
    private(set) var currentSnapshot: LocationSnapshot?
    private(set) var lastError: LocationError?

    private let manager = CLLocationManager()
    private let proxy = LocationManagerProxy()
    private var eventTask: Task<Void, Never>?
    private var permissionContinuation: CheckedContinuation<PermissionStatus, Never>?
    private var isUpdating = false

    init() {
        permissionStatus = PermissionStatus(manager.authorizationStatus)
        manager.delegate = proxy
        manager.desiredAccuracy = LocationConstants.Accuracy.desired
        manager.distanceFilter = LocationConstants.Updates.distanceFilter
        observeEvents()
    }

    // MARK: - Permission

    func requestPermission() async -> PermissionStatus {
        guard permissionStatus == .notDetermined else { return permissionStatus }

        manager.requestWhenInUseAuthorization()

        return await withCheckedContinuation { continuation in
            permissionContinuation = continuation
        }
    }

    // MARK: - Updates

    func startUpdates() {
        guard permissionStatus.isAuthorized, !isUpdating else { return }

        isUpdating = true
        manager.startUpdatingLocation()
    }

    func stopUpdates() {
        guard isUpdating else { return }

        isUpdating = false
        manager.stopUpdatingLocation()
    }

    // MARK: - Private

    private func observeEvents() {
        eventTask = Task { [weak self, events = proxy.events] in
            for await event in events {
                guard let self else { return }
                apply(event)
            }
        }
    }

    private func apply(_ event: LocationManagerProxy.Event) {
        switch event {
        case let .authorization(status):
            handleAuthorizationChange(status)
        case let .location(snapshot):
            currentSnapshot = snapshot
            lastError = nil
        case let .failure(error):
            lastError = error
        case .heading:
            break
        }
    }

    private func handleAuthorizationChange(_ status: PermissionStatus) {
        permissionStatus = status

        if status != .notDetermined, let continuation = permissionContinuation {
            permissionContinuation = nil
            continuation.resume(returning: status)
        }

        if !status.isAuthorized {
            stopUpdates()
        }
    }
}
