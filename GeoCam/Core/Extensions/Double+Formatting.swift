//
//  Double+Formatting.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

nonisolated extension Double {

    /// Metre cinsinden, tam sayıya yuvarlanmış ölçüm metni (örn. "1.240 m").
    var metersText: String {
        Measurement(value: self, unit: UnitLength.meters)
            .formatted(
                .measurement(
                    width: .abbreviated,
                    usage: .asProvided,
                    numberFormatStyle: .number.precision(.fractionLength(0))
                )
            )
    }
}
