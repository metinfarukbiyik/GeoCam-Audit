//
//  AddressResolving.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Konum değiştikçe güncel adresi sağlayan bileşeni soyutlar.
@MainActor
protocol AddressResolving: AnyObject {
    var currentAddress: PostalAddress? { get }

    func start()
    func stop()
}
