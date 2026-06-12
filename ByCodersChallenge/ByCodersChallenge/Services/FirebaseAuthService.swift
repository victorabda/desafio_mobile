//
//  FirebaseAuthService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseAuth

final class FirebaseAuthService: AuthService {
    /// Minimal projection of the Firebase user payload the domain cares
    /// about. `FirebaseAuth.User` cannot be instantiated in tests, so the
    /// SDK boundary trades in this value type instead.
    struct SignedInUser {
        let uid: String
        let email: String?
        let displayName: String?
    }

    /// Seam over `Auth.auth().signIn`: production keeps the real SDK call
    /// (default argument below), while unit tests inject a stub — the actual
    /// network round trip is the only line left uncovered by design.
    private let signInHandler: (_ email: String, _ password: String) async throws -> SignedInUser

    init(
        signInHandler: @escaping (_ email: String, _ password: String) async throws -> SignedInUser = { email, password in
            let user = try await Auth.auth().signIn(withEmail: email, password: password).user
            return SignedInUser(uid: user.uid, email: user.email, displayName: user.displayName)
        }
    ) {
        self.signInHandler = signInHandler
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        let user = try await signInHandler(email, password)

        // Map to the domain model at the boundary so FirebaseAuth types never
        // leak into ViewModels.
        return AuthenticatedUser(
            id: user.uid,
            email: user.email,
            displayName: user.displayName
        )
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
