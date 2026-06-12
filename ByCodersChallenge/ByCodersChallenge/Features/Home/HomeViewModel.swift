//
//  HomeViewModel.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Combine
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case loaded(UserLocation)
        case permissionDenied
        case failed(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var isLoggingOut = false
    @Published var logoutErrorMessage: String?

    private let authService: AuthService
    private let locationService: LocationService
    private let locationRepository: LocationRepository
    private let analyticsService: AnalyticsService
    private let crashlyticsService: CrashlyticsService
    private let userRepository: UserRepository
    private let session: AppSession

    init(
        authService: AuthService,
        locationService: LocationService,
        locationRepository: LocationRepository,
        analyticsService: AnalyticsService,
        crashlyticsService: CrashlyticsService,
        userRepository: UserRepository,
        session: AppSession
    ) {
        self.authService = authService
        self.locationService = locationService
        self.locationRepository = locationRepository
        self.analyticsService = analyticsService
        self.crashlyticsService = crashlyticsService
        self.userRepository = userRepository
        self.session = session
    }

    var userDisplayName: String {
        session.currentUser?.displayName
            ?? session.currentUser?.email
            ?? L10n.genericUser
    }

    func load() async {
        state = .loading

        do {
            await locationService.requestAuthorization()
            let location = try await locationService.currentLocation()

            try await locationRepository.saveLastLocation(location)

            if let userId = session.currentUser?.id {
                analyticsService.track(.homeRendered(
                    userId: userId,
                    latitude: location.latitude,
                    longitude: location.longitude
                ))
            }

            state = .loaded(location)
        } catch LocationError.permissionDenied {
            state = .permissionDenied
        } catch {
            state = .failed(L10n.locationLoadError)

            crashlyticsService.record(error: error, context: [
                "screen": "home",
                "action": "load_current_location"
            ])
        }
    }

    func logout() async {
        guard !isLoggingOut else { return }

        isLoggingOut = true
        logoutErrorMessage = nil

        do {
            try authService.signOut()
            try await userRepository.deleteLoggedUser()
            session.setLoggedOut()
        } catch {
            logoutErrorMessage = L10n.logoutError
            crashlyticsService.record(error: error, context: [
                "screen": "home",
                "action": "logout"
            ])
        }

        isLoggingOut = false
    }
}
