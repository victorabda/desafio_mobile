//
//  FirebaseServicesTests.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseCore
import Testing
@testable import ByCodersChallenge

/// Smoke tests for the thin Firebase wrappers. The test host app configures
/// Firebase at launch, so these exercise the real SDK entry points locally
/// (events and reports are only queued; nothing requires network).
/// `FirebaseAuthService.signIn` is intentionally not covered here because it
/// always performs a network round trip to the Firebase backend.
@MainActor
struct FirebaseServicesTests {
    @Test
    func analyticsServiceLogsEveryTrackedEvent() {
        let sut = FirebaseAnalyticsService()

        sut.track(.loginSuccess(userId: "test-user", provider: "firebase_auth"))
        sut.track(.homeRendered(userId: "test-user", latitude: -23.5505, longitude: -46.6333))
    }

    @Test
    func crashlyticsServiceRecordsErrorWithContext() {
        let sut = FirebaseCrashlyticsService()

        sut.record(error: TestError.expected, context: [
            "screen": "unit_test",
            "action": "crashlytics_smoke_test"
        ])
    }

    @Test
    func authServiceSignsOutWithoutAnActiveSession() throws {
        let sut = FirebaseAuthService()

        try sut.signOut()
        try sut.signOut()
    }

    @Test
    func signInForwardsCredentialsAndMapsFirebaseUserToDomain() async throws {
        var receivedEmail: String?
        var receivedPassword: String?
        let sut = FirebaseAuthService { email, password in
            receivedEmail = email
            receivedPassword = password
            return FirebaseAuthService.SignedInUser(
                uid: "uid-123",
                email: email,
                displayName: "Test User"
            )
        }

        let user = try await sut.signIn(email: "teste@teste.com", password: "123456")

        #expect(receivedEmail == "teste@teste.com")
        #expect(receivedPassword == "123456")
        #expect(user == AuthenticatedUser(
            id: "uid-123",
            email: "teste@teste.com",
            displayName: "Test User"
        ))
    }

    @Test
    func signInKeepsOptionalFirebaseFieldsAsNil() async throws {
        let sut = FirebaseAuthService { _, _ in
            FirebaseAuthService.SignedInUser(uid: "uid-123", email: nil, displayName: nil)
        }

        let user = try await sut.signIn(email: "teste@teste.com", password: "123456")

        #expect(user == AuthenticatedUser(id: "uid-123", email: nil, displayName: nil))
    }

    @Test
    func signInPropagatesFirebaseFailure() async {
        let sut = FirebaseAuthService { _, _ in
            throw TestError.expected
        }

        await #expect(throws: TestError.expected) {
            _ = try await sut.signIn(email: "teste@teste.com", password: "123456")
        }
    }
}
