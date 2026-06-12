import Testing
@testable import ByCodersChallenge

@MainActor
struct HomeViewModelTests {
    @Test
    func successfulLoadRequestsLocationPersistsTracksAndShowsMap() async {
        let context = makeSUT()

        await context.sut.load()

        #expect(context.locationService.requestAuthorizationCallCount == 1)
        #expect(context.locationService.currentLocationCallCount == 1)
        #expect(context.locationRepository.savedLocations == [.fixture])
        #expect(context.sut.state == .loaded(.fixture))
        #expect(context.analytics.trackedEvents.map(\.name) == ["home_rendered"])
        #expect(context.analytics.trackedEvents.first?.parameters["user_id"] as? String == "user-id")
        #expect(context.analytics.trackedEvents.first?.parameters["latitude"] as? Double == UserLocation.fixture.latitude)
        #expect(context.analytics.trackedEvents.first?.parameters["longitude"] as? Double == UserLocation.fixture.longitude)
        #expect(context.crashlytics.recordedErrors.isEmpty)
    }

    @Test
    func permissionDeniedShowsDedicatedStateWithoutRecordingError() async {
        let context = makeSUT()
        context.locationService.result = .failure(LocationError.permissionDenied)

        await context.sut.load()

        #expect(context.sut.state == .permissionDenied)
        #expect(context.locationRepository.savedLocations.isEmpty)
        #expect(context.analytics.trackedEvents.isEmpty)
        #expect(context.crashlytics.recordedErrors.isEmpty)
    }

    @Test
    func locationFailureShowsErrorAndRecordsCrashlytics() async {
        let context = makeSUT()
        context.locationService.result = .failure(TestError.expected)

        await context.sut.load()

        #expect(context.sut.state == .failed(L10n.locationLoadError))
        #expect(context.crashlytics.recordedErrors.count == 1)
        #expect(context.crashlytics.recordedContexts.first?["screen"] == "home")
        #expect(context.crashlytics.recordedContexts.first?["action"] == "load_current_location")
    }

    @Test
    func persistenceFailureShowsErrorAndDoesNotTrackRendering() async {
        let context = makeSUT()
        context.locationRepository.saveError = TestError.expected

        await context.sut.load()

        #expect(context.sut.state == .failed(L10n.locationLoadError))
        #expect(context.analytics.trackedEvents.isEmpty)
        #expect(context.crashlytics.recordedErrors.count == 1)
    }

    @Test
    func successfulLogoutSignsOutDeletesUserAndUpdatesSession() async {
        let context = makeSUT()

        await context.sut.logout()

        #expect(context.auth.signOutCallCount == 1)
        #expect(context.userRepository.deleteCallCount == 1)
        #expect(context.session.currentUser == nil)
        #expect(!context.sut.isLoggingOut)
        #expect(context.sut.logoutErrorMessage == nil)
    }

    @Test
    func logoutFailureKeepsSessionAndRecordsCrashlytics() async {
        let context = makeSUT()
        context.auth.signOutError = TestError.expected

        await context.sut.logout()

        #expect(context.session.currentUser == .fixture)
        #expect(context.userRepository.deleteCallCount == 0)
        #expect(context.sut.logoutErrorMessage == L10n.logoutError)
        #expect(context.crashlytics.recordedContexts.first?["action"] == "logout")
    }

    @Test
    func localDeletionFailureKeepsSessionAndRecordsCrashlytics() async {
        let context = makeSUT()
        context.userRepository.deleteError = TestError.expected

        await context.sut.logout()

        #expect(context.auth.signOutCallCount == 1)
        #expect(context.userRepository.deleteCallCount == 1)
        #expect(context.session.currentUser == .fixture)
        #expect(context.sut.logoutErrorMessage == L10n.logoutError)
        #expect(context.crashlytics.recordedContexts.first?["action"] == "logout")
    }

    private func makeSUT() -> Context {
        let auth = MockAuthService()
        let locationService = MockLocationService()
        let locationRepository = MockLocationRepository()
        let analytics = MockAnalyticsService()
        let crashlytics = MockCrashlyticsService()
        let userRepository = MockUserRepository()
        let session = AppSession()
        session.setLoggedInUser(.fixture)

        let sut = HomeViewModel(
            authService: auth,
            locationService: locationService,
            locationRepository: locationRepository,
            analyticsService: analytics,
            crashlyticsService: crashlytics,
            userRepository: userRepository,
            session: session
        )

        return Context(
            sut: sut,
            auth: auth,
            locationService: locationService,
            locationRepository: locationRepository,
            analytics: analytics,
            crashlytics: crashlytics,
            userRepository: userRepository,
            session: session
        )
    }

    private struct Context {
        let sut: HomeViewModel
        let auth: MockAuthService
        let locationService: MockLocationService
        let locationRepository: MockLocationRepository
        let analytics: MockAnalyticsService
        let crashlytics: MockCrashlyticsService
        let userRepository: MockUserRepository
        let session: AppSession
    }
}
