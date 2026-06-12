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
    /// Finite states the Home screen can render. Modeling them as an enum
    /// (instead of independent booleans) makes invalid combinations such as
    /// "loading + error" unrepresentable.
    enum State: Equatable {
        case loading
        case loaded(UserLocation)
        /// GPS could not be read, but a previously persisted location exists.
        /// The map is still shown, flagged as potentially outdated.
        case staleLocation(UserLocation, reason: StaleLocationReason)
        case permissionDenied
        case failed(String)
    }

    /// Why the displayed location is stale — drives the recovery action the
    /// banner offers (open Settings vs. retry).
    enum StaleLocationReason: Equatable {
        case permissionDenied
        case locationUnavailable
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

    /// Loads the current position, persists it as the new "last location" and
    /// tracks the `home_rendered` event. When the GPS read fails, the last
    /// persisted location is used as a degraded-but-useful fallback; only
    /// when there is nothing saved do we surface the blocking error states.
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
            if let lastLocation = await fetchLastSavedLocation() {
                state = .staleLocation(lastLocation, reason: .permissionDenied)
            } else {
                state = .permissionDenied
            }
        } catch {
            crashlyticsService.record(error: error, context: [
                "screen": "home",
                "action": "load_current_location"
            ])

            if let lastLocation = await fetchLastSavedLocation() {
                state = .staleLocation(lastLocation, reason: .locationUnavailable)
            } else {
                state = .failed(L10n.locationLoadError)
            }
        }
    }

    /// Best-effort read of the persisted location: a failure here must not
    /// mask the original GPS error, so it is only reported to Crashlytics
    /// and treated as "no fallback available".
    private func fetchLastSavedLocation() async -> UserLocation? {
        do {
            return try await locationRepository.fetchLastLocation()
        } catch {
            crashlyticsService.record(error: error, context: [
                "screen": "home",
                "action": "fetch_last_location"
            ])
            return nil
        }
    }

    /// Signs out remotely first, then clears the persisted user and the last
    /// saved location (personal data must not outlive the session); the
    /// session is only flipped to logged-out after every step succeeds, so a
    /// failure leaves the user signed in with a visible error instead of a
    /// half-cleared state.
    func logout() async {
        guard !isLoggingOut else { return }

        isLoggingOut = true
        logoutErrorMessage = nil

        do {
            try authService.signOut()
            try await userRepository.deleteLoggedUser()
            try await locationRepository.deleteLastLocation()
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
