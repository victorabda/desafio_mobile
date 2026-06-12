//
//  ByCodersChallengeApp.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation

@MainActor
enum PreviewFactory {
    static func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService: PreviewAuthService(),
            analyticsService: PreviewAnalyticsService(),
            crashlyticsService: PreviewCrashlyticsService(),
            userRepository: PreviewUserRepository(),
            session: AppSession()
        )
    }

    static func makeHomeViewModel() -> HomeViewModel {
        let session = AppSession()
        session.setLoggedInUser(AuthenticatedUser(
            id: "preview-user",
            email: "teste@teste.com",
            displayName: "Usuário Preview"
        ))

        return HomeViewModel(
            authService: PreviewAuthService(),
            locationService: PreviewLocationService(),
            locationRepository: PreviewLocationRepository(),
            analyticsService: PreviewAnalyticsService(),
            crashlyticsService: PreviewCrashlyticsService(),
            userRepository: PreviewUserRepository(),
            session: session
        )
    }
}

private struct PreviewAuthService: AuthService {
    func signIn(email: String, password: String) async throws -> AuthenticatedUser {
        AuthenticatedUser(id: "preview-user", email: email, displayName: "Usuário Preview")
    }

    func signOut() throws {}
}

private struct PreviewAnalyticsService: AnalyticsService {
    func track(_ event: AnalyticsEvent) {}
}

private struct PreviewCrashlyticsService: CrashlyticsService {
    func record(error: Error, context: [String: String]) {}
}

private struct PreviewUserRepository: UserRepository {
    func saveLoggedUser(_ user: AuthenticatedUser) async throws {}
    func loggedUser() async throws -> AuthenticatedUser? { nil }
    func deleteLoggedUser() async throws {}
}

private struct PreviewLocationRepository: LocationRepository {
    func saveLastLocation(_ location: UserLocation) async throws {}
}

private struct PreviewLocationService: LocationService {
    func requestAuthorization() async {}

    func currentLocation() async throws -> UserLocation {
        UserLocation(latitude: -23.5505, longitude: -46.6333)
    }
}
