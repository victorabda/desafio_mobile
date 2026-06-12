//
//  ByCodersChallengeApp.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation

/// Strings that ViewModels expose as plain `String` (e.g. error messages).
/// Views use string-catalog keys directly; this exists so ViewModels stay
/// free of `LocalizedStringKey`/SwiftUI imports.
enum L10n {
    static var genericUser: String {
        String(localized: "common.user")
    }

    static var loginError: String {
        String(localized: "login.error")
    }

    static var locationLoadError: String {
        String(localized: "home.location.error")
    }

    static var logoutError: String {
        String(localized: "home.logout.error.message")
    }
}
