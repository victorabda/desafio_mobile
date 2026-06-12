//
//  AppContainer.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 10/06/26.
//

import SwiftData

/// Composition root: owns every service/repository instance and wires them
/// into ViewModels. Dependencies are held as protocols, so the whole graph
/// can be swapped at a single point — Firebase + Core Location in production,
/// deterministic fakes when a UI test scenario is detected at launch.
@MainActor
final class AppContainer {
    let modelContainer: ModelContainer
    let session: AppSession

    private let authService: AuthService
    private let analyticsService: AnalyticsService
    private let crashlyticsService: CrashlyticsService
    private let locationService: LocationService
    private let userRepository: UserRepository
    private let locationRepository: LocationRepository
    private var didRestoreSession = false

    init() {
        let scenario = UITestScenario.current

        do {
            modelContainer = try LocalDatabase.makeModelContainer(inMemory: scenario != nil)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        session = AppSession()

        if let scenario {
            let loggedUser = scenario.startsOnHome
                ? AuthenticatedUser(id: "ui-test-user", email: "teste@teste.com", displayName: "Usuário UI Test")
                : nil

            authService = UITestAuthService(shouldFail: scenario == .loginFailure)
            analyticsService = UITestAnalyticsService()
            crashlyticsService = UITestCrashlyticsService()
            locationService = UITestLocationService(result: scenario.locationResult)
            userRepository = UITestUserRepository(user: loggedUser)
            locationRepository = UITestLocationRepository(savedLocation: scenario.savedLocation)
        } else {
            authService = FirebaseAuthService()
            analyticsService = FirebaseAnalyticsService()
            crashlyticsService = FirebaseCrashlyticsService()
            locationService = CoreLocationService()
            userRepository = SwiftDataUserRepository(modelContext: modelContainer.mainContext)
            locationRepository = SwiftDataLocationRepository(modelContext: modelContainer.mainContext)
        }
    }

    /// Memberwise initializer used by unit tests to inject mocks directly.
    init(
        modelContainer: ModelContainer,
        session: AppSession,
        authService: AuthService,
        analyticsService: AnalyticsService,
        crashlyticsService: CrashlyticsService,
        locationService: LocationService,
        userRepository: UserRepository,
        locationRepository: LocationRepository
    ) {
        self.modelContainer = modelContainer
        self.session = session
        self.authService = authService
        self.analyticsService = analyticsService
        self.crashlyticsService = crashlyticsService
        self.locationService = locationService
        self.userRepository = userRepository
        self.locationRepository = locationRepository
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService: authService,
            analyticsService: analyticsService,
            crashlyticsService: crashlyticsService,
            userRepository: userRepository,
            session: session
        )
    }

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            authService: authService,
            locationService: locationService,
            locationRepository: locationRepository,
            analyticsService: analyticsService,
            crashlyticsService: crashlyticsService,
            userRepository: userRepository,
            session: session
        )
    }

    /// Resolves the initial `AuthState` from the persisted user, exactly once
    /// per launch. Any persistence failure is reported and falls back to the
    /// logged-out state so the app never gets stuck on the restoring screen.
    func restoreSession() async {
        guard !didRestoreSession else { return }
        didRestoreSession = true

        do {
            if let user = try await userRepository.loggedUser() {
                session.setLoggedInUser(user)
            } else {
                session.setLoggedOut()
            }
        } catch {
            crashlyticsService.record(error: error, context: [
                "screen": "app_start",
                "action": "restore_session"
            ])
            session.setLoggedOut()
        }
    }
}

private extension UITestScenario {
    var startsOnHome: Bool {
        switch self {
        case .homeSuccess, .homePermissionDenied, .homeFailure,
             .homeStaleLocationPermissionDenied, .homeStaleLocationUnavailable:
            true
        case .loginSuccess, .loginFailure:
            false
        }
    }

    var locationResult: UITestLocationService.Result {
        switch self {
        case .homePermissionDenied, .homeStaleLocationPermissionDenied:
            .permissionDenied
        case .homeFailure, .homeStaleLocationUnavailable:
            .failure
        case .loginSuccess, .loginFailure, .homeSuccess:
            .success
        }
    }

    /// Pre-seeded location for scenarios that exercise the stale-location
    /// fallback. Returns `nil` for every other scenario so the repository
    /// behaves as if no location has ever been saved.
    var savedLocation: UserLocation? {
        switch self {
        case .homeStaleLocationPermissionDenied, .homeStaleLocationUnavailable:
            UserLocation(latitude: -23.5505, longitude: -46.6333)
        default:
            nil
        }
    }
}
