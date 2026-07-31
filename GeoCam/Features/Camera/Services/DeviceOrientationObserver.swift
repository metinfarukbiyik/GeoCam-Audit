//
//  DeviceOrientationObserver.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation
import Observation
import UIKit

/// Ekran çevirme kilidi açıkken bile fiziksel cihaz yönünü izler.
@MainActor
@Observable
final class DeviceOrientationObserver {

    private(set) var orientation: DeviceDisplayOrientation = .portrait

    private var notificationToken: NSObjectProtocol?
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        refresh()

        notificationToken = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        if let notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
            self.notificationToken = nil
        }

        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    private func refresh() {
        guard let next = DeviceDisplayOrientation(deviceOrientation: UIDevice.current.orientation) else {
            return
        }

        guard next != orientation else { return }
        orientation = next
    }
}
