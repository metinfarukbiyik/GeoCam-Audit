//
//  CompassService.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation

/// CoreLocation heading güncellemelerini yöneten pusula servisi.
@MainActor
@Observable
final class CompassService: CompassServicing {

    private(set) var currentReading: CompassReading?

    nonisolated var isAvailable: Bool { CLLocationManager.headingAvailable() }

    private let manager = CLLocationManager()
    private let proxy = LocationManagerProxy()
    private var eventTask: Task<Void, Never>?
    private var isUpdating = false

    init() {
        manager.delegate = proxy
        manager.headingFilter = LocationConstants.Updates.headingFilter
        observeEvents()
    }

    func startUpdates() {
        guard isAvailable, !isUpdating else { return }

        isUpdating = true
        manager.startUpdatingHeading()
    }

    func stopUpdates() {
        guard isUpdating else { return }

        isUpdating = false
        manager.stopUpdatingHeading()
    }

    private func observeEvents() {
        eventTask = Task { [weak self, events = proxy.events] in
            for await event in events {
                guard let self else { return }
                if case let .heading(reading) = event {
                    currentReading = reading
                }
            }
        }
    }
}
