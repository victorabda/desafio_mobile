//
//  AppContainer.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 10/06/26.
//

import SwiftData

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
            locationRepository = UITestLocationRepository()
        } else {
            authService = FirebaseAuthService()
            analyticsService = FirebaseAnalyticsService()
            crashlyticsService = FirebaseCrashlyticsService()
            locationService = CoreLocationService()
            userRepository = SwiftDataUserRepository(modelContext: modelContainer.mainContext)
            locationRepository = SwiftDataLocationRepository(modelContext: modelContainer.mainContext)
        }
    }

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
        case .homeSuccess, .homePermissionDenied, .homeFailure:
            true
        case .loginSuccess, .loginFailure:
            false
        }
    }

    var locationResult: UITestLocationService.Result {
        switch self {
        case .homePermissionDenied:
            .permissionDenied
        case .homeFailure:
            .failure
        case .loginSuccess, .loginFailure, .homeSuccess:
            .success
        }
    }
}
