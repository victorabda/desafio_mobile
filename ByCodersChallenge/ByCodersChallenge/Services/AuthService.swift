//
//  AuthService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

/// Authentication boundary. ViewModels depend on this protocol instead of
/// FirebaseAuth, which keeps them unit-testable and would make swapping the
/// identity provider a one-file change.
protocol AuthService {
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() throws
}
