//
//  AddressResolver.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import CoreLocation
import OSLog

/// Konum güncellemelerini izleyip adresi çözümler.
/// Aynı bölge için tekrarlanan istekleri ve başarısızlık sonrası hızlı denemeleri engeller.
@MainActor
@Observable
final class AddressResolver: AddressResolving {

    private(set) var currentAddress: PostalAddress?

    private let locationService: any LocationServicing
    private let geocodingService: any GeocodingServicing

    private var resolveTask: Task<Void, Never>?
    private var lastResolvedCoordinate: CLLocationCoordinate2D?
    private var nextRetryDate: Date?
    private var isObserving = false

    init(locationService: any LocationServicing, geocodingService: any GeocodingServicing) {
        self.locationService = locationService
        self.geocodingService = geocodingService
    }

    func start() {
        guard !isObserving else { return }

        isObserving = true
        observeSnapshot()
        resolveIfNeeded()
    }

    func stop() {
        isObserving = false
        resolveTask?.cancel()
        resolveTask = nil
    }

    // MARK: - Private

    /// Observation, değişimi yalnızca bir kez bildirir; her bildirimden sonra takip yeniden kurulur.
    private func observeSnapshot() {
        withObservationTracking {
            _ = locationService.currentSnapshot
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, isObserving else { return }

                resolveIfNeeded()
                observeSnapshot()
            }
        }
    }

    private func resolveIfNeeded() {
        guard resolveTask == nil,
              let coordinate = locationService.currentSnapshot?.coordinate,
              shouldResolve(for: coordinate)
        else { return }

        lastResolvedCoordinate = coordinate
        resolveTask = Task { [weak self] in
            await self?.resolve(coordinate)
            self?.resolveTask = nil
        }
    }

    private func resolve(_ coordinate: CLLocationCoordinate2D) async {
        do {
            currentAddress = try await geocodingService.address(for: coordinate)
            nextRetryDate = nil
        } catch {
            // Adres alınamazsa arayüz koordinatlara düşer; kullanıcıya hata gösterilmez.
            AppLogger.location.debug("Adres çözümlenemedi, koordinatlara düşülüyor.")
            lastResolvedCoordinate = nil
            nextRetryDate = .now.addingTimeInterval(LocationConstants.Geocoding.retryCooldown)
        }
    }

    private func shouldResolve(for coordinate: CLLocationCoordinate2D) -> Bool {
        if let nextRetryDate, nextRetryDate > .now { return false }

        guard let lastResolvedCoordinate else { return true }

        return lastResolvedCoordinate.distance(to: coordinate)
            >= LocationConstants.Geocoding.minimumDistanceBetweenRequests
    }
}
