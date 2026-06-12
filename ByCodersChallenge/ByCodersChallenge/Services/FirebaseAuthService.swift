//
//  FirebaseAuthService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseAuth

final class FirebaseAuthService: AuthService {
    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let user = result.user

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
