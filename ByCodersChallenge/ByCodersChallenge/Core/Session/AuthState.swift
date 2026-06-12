//
//  AuthState.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

struct AuthenticatedUser: Equatable, Sendable {
    let id: String
    let email: String?
    let displayName: String?
}

enum AuthState: Equatable {
    case restoring
    case loggedOut
    case loggedIn(AuthenticatedUser)
}
