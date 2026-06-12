//
//  AppSession.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Combine

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var authState: AuthState = .restoring

    var currentUser: AuthenticatedUser? {
        guard case let .loggedIn(user) = authState else { return nil }
        return user
    }

    func setLoggedInUser(_ user: AuthenticatedUser) {
        authState = .loggedIn(user)
    }

    func setLoggedOut() {
        authState = .loggedOut
    }
}
