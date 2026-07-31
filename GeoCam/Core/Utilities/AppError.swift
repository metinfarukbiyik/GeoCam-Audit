//
//  AppError.swift
//  GeoCam
//
//  Created by Metin Faruk Bıyık on 30.07.2026.
//

import Foundation

/// Kullanıcıya gösterilebilir hata tipleri için ortak sözleşme.
nonisolated protocol UserPresentableError: LocalizedError {
    func presentableTitle(language: AppLanguage) -> String
    func presentableRecovery(language: AppLanguage) -> String?
}

nonisolated extension UserPresentableError {
    var errorDescription: String? {
        presentableTitle(language: .turkish)
    }

    var recoverySuggestionText: String? {
        presentableRecovery(language: .turkish)
    }
}

/// Henüz uygulanmamış iskelet davranışları işaretler.
/// İlgili fazlar tamamlandıkça bu hata kullanımdan kalkacaktır.
nonisolated struct NotImplementedError: Error {
    let feature: String
}
