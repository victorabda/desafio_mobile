import Testing
@testable import ByCodersChallenge

@MainActor
struct AppContainerTests {
    @Test
    func restoreSessionSetsPersistedUserAsLoggedIn() async throws {
        let context = try makeContext(loggedUserResult: .success(.fixture))

        await context.sut.restoreSession()

        #expect(context.session.currentUser == .fixture)
        #expect(context.userRepository.loggedUserCallCount == 1)
        #expect(context.crashlytics.recordedErrors.isEmpty)
    }

    @Test
    func restoreSessionSetsLoggedOutWhenThereIsNoPersistedUser() async throws {
        let context = try makeContext(loggedUserResult: .success(nil))

        await context.sut.restoreSession()

        #expect(context.session.authState == .loggedOut)
        #expect(context.userRepository.loggedUserCallCount == 1)
        #expect(context.crashlytics.recordedErrors.isEmpty)
    }

    @Test
    func restoreSessionFailureRecordsCrashlyticsAndSetsLoggedOut() async throws {
        let context = try makeContext(loggedUserResult: .failure(TestError.expected))

        await context.sut.restoreSession()

        #expect(context.session.authState == .loggedOut)
        #expect(context.crashlytics.recordedErrors.count == 1)
        #expect(context.crashlytics.recordedContexts.first?["screen"] == "app_start")
        #expect(context.crashlytics.recordedContexts.first?["action"] == "restore_session")
    }

    @Test
    func restoreSessionOnlyRunsOnce() async throws {
        let context = try makeContext(loggedUserResult: .success(.fixture))

        await context.sut.restoreSession()
        await context.sut.restoreSession()

        #expect(context.userRepository.loggedUserCallCount == 1)
    }

    private func makeContext(
        loggedUserResult: Result<AuthenticatedUser?, Error>
    ) throws -> Context {
        let modelContainer = try LocalDatabase.makeModelContainer(inMemory: true)
        let session = AppSession()
        let userRepository = MockUserRepository()
        let crashlytics = MockCrashlyticsService()
        userRepository.loggedUserResult = loggedUserResult

        let sut = AppContainer(
            modelContainer: modelContainer,
            session: session,
            authService: MockAuthService(),
            analyticsService: MockAnalyticsService(),
            crashlyticsService: crashlytics,
            locationService: MockLocationService(),
            userRepository: userRepository,
            locationRepository: MockLocationRepository()
        )

        return Context(
            sut: sut,
            session: session,
            userRepository: userRepository,
            crashlytics: crashlytics
        )
    }

    private struct Context {
        let sut: AppContainer
        let session: AppSession
        let userRepository: MockUserRepository
        let crashlytics: MockCrashlyticsService
    }
}
