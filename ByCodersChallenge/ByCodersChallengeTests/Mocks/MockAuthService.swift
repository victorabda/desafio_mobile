//
//  MockAuthService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

@testable import ByCodersChallenge

@MainActor
final class MockAuthService: AuthService {
    var signInResult: Result<AuthenticatedUser, Error> = .success(.fixture)
    var signOutError: Error?
    private(set) var receivedEmail: String?
    private(set) var receivedPassword: String?
    private(set) var signOutCallCount = 0

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        receivedEmail = email
        receivedPassword = password
        return try signInResult.get()
    }

    func signOut() throws {
        signOutCallCount += 1
        if let signOutError {
            throw signOutError
        }
    }
}

extension AuthenticatedUser {
    static let fixture = AuthenticatedUser(
        id: "user-id",
        email: "teste@teste.com",
        displayName: "Usuário Teste"
    )
}

enum TestError: Error {
    case expected
}
