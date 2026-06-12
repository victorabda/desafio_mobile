//
//  AuthService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

protocol AuthService {
    func signIn(email: String, password: String) async throws -> AuthenticatedUser
    func signOut() throws
}
