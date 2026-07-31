//
//  ErrorAlertItem.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Alert sunumu için hazırlanmış hata bilgisi.
nonisolated struct ErrorAlertItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String?

    init(title: String, message: String?) {
        self.title = title
        self.message = message
    }

    init(_ error: any UserPresentableError) {
        self.init(
            title: error.errorDescription ?? AppConstants.Info.appName,
            message: error.recoverySuggestionText
        )
    }
}
