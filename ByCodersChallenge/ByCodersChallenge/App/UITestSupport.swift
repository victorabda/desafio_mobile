//
//  ByCodersChallengeApp.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation

/// Launch-argument-driven scenarios that make XCUITests deterministic: each
/// case selects a fixed dependency graph (fakes below) so E2E runs never
/// depend on network, Firebase, or real GPS. Compiled out of Release builds.
enum UITestScenario: String {
    case loginSuccess = "-ui-testing-login-success"
    case loginFailure = "-ui-testing-login-failure"
    case homeSuccess = "-ui-testing-home-success"
    case homePermissionDenied = "-ui-testing-home-permission-denied"
    case homeFailure = "-ui-testing-home-failure"
    /// GPS permission denied, but a previously saved location exists in the repository.
    case homeStaleLocationPermissionDenied = "-ui-testing-home-stale-permission-denied"
    /// GPS unavailable (generic failure), but a previously saved location exists.
    case homeStaleLocationUnavailable = "-ui-testing-home-stale-unavailable"

    static var current: UITestScenario? {
#if DEBUG
        ProcessInfo.processInfo.arguments.lazy.compactMap(UITestScenario.init(rawValue:)).first
#else
        nil
#endif
    }
}

@MainActor
final class UITestAuthService: AuthService {
    private let shouldFail: Bool

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        guard !shouldFail else { throw UITestError.expectedFailure }
        return AuthenticatedUser(id: "ui-test-user", email: email, displayName: "Usuário UI Test")
    }

    func signOut() throws {}
}

@MainActor
final class UITestUserRepository: UserRepository {
    private var user: AuthenticatedUser?

    init(user: AuthenticatedUser? = nil) {
        self.user = user
    }

    func saveLoggedUser(_ user: AuthenticatedUser) async throws {
        self.user = user
    }

    func loggedUser() async throws -> AuthenticatedUser? {
        user
    }

    func deleteLoggedUser() async throws {
        user = nil
    }
}

@MainActor
final class UITestLocationService: LocationService {
    enum Result {
        case success
        case permissionDenied
        case failure
    }

    private let result: Result

    init(result: Result) {
        self.result = result
    }

    func requestAuthorization() async {}

    func currentLocation() async throws -> UserLocation {
        switch result {
        case .success:
            UserLocation(latitude: -23.5505, longitude: -46.6333)
        case .permissionDenied:
            throw LocationError.permissionDenied
        case .failure:
            throw UITestError.expectedFailure
        }
    }
}

@MainActor
final class UITestLocationRepository: LocationRepository {
    /// Pre-seeded location returned by `fetchLastLocation`, modelling the case
    /// where the user previously visited the Home screen and the position was
    /// persisted. `nil` simulates a first-launch with no saved data.
    private let savedLocation: UserLocation?

    init(savedLocation: UserLocation? = nil) {
        self.savedLocation = savedLocation
    }

    func saveLastLocation(_ location: UserLocation) async throws {}
    func fetchLastLocation() async throws -> UserLocation? { savedLocation }
    func deleteLastLocation() async throws {}
}

@MainActor
final class UITestAnalyticsService: AnalyticsService {
    func track(_ event: AnalyticsEvent) {}
}

@MainActor
final class UITestCrashlyticsService: CrashlyticsService {
    func record(error: Error, context: [String: String]) {}
}

enum UITestError: Error {
    case expectedFailure
}
