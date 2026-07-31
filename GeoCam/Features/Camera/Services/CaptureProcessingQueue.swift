//
//  CaptureProcessingQueue.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Seri çekimde damga/kayıt işlerini sınırlı paralellikte sıraya alır.
/// Sınırsız Task açılmasını engelleyerek bellek ve CPU çakışmasını azaltır.
actor CaptureProcessingQueue {

    private let maxConcurrent: Int
    private var activeCount = 0
    private var pending: [@Sendable () async -> Void] = []

    init(maxConcurrent: Int = CameraConstants.Capture.maxConcurrentProcessing) {
        self.maxConcurrent = max(1, maxConcurrent)
    }

    /// İşi kuyruğa ekler; uygun slot açılınca çalıştırır.
    func enqueue(_ work: @escaping @Sendable () async -> Void) {
        pending.append(work)
        pump()
    }

    /// Bekleyen + çalışan iş sayısı.
    var outstandingCount: Int {
        pending.count + activeCount
    }

    private func pump() {
        while activeCount < maxConcurrent, !pending.isEmpty {
            let work = pending.removeFirst()
            activeCount += 1

            Task {
                await work()
                await jobDidFinish()
            }
        }
    }

    private func jobDidFinish() {
        activeCount = max(0, activeCount - 1)
        pump()
    }
}
