//
//  CompassServicing.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Manyetik pusula ölçümlerini soyutlar.
@MainActor
protocol CompassServicing: AnyObject {
    var isAvailable: Bool { get }
    var currentReading: CompassReading? { get }

    func startUpdates()
    func stopUpdates()
}
