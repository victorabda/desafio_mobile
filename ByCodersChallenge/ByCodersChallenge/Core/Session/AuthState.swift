//
//  AuthState.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

/// Domain representation of the signed-in user, deliberately decoupled from
/// `FirebaseAuth.User` so ViewModels never depend on the Firebase SDK.
struct AuthenticatedUser: Equatable, Sendable {
    let id: String
    let email: String?
    let displayName: String?
}

/// Tri-state instead of a boolean: `restoring` models the async gap between
/// launch and reading the persisted user, avoiding a login-screen flash for
/// users who are already signed in.
enum AuthState: Equatable {
    case restoring
    case loggedOut
    case loggedIn(AuthenticatedUser)
}
