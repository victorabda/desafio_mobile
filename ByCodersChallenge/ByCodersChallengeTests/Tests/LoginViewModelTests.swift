import Testing
@testable import ByCodersChallenge

@MainActor
struct LoginViewModelTests {
    @Test
    func loginButtonRequiresValidEmailAndPassword() {
        let sut = makeSUT().sut

        #expect(!sut.isLoginButtonEnabled)

        sut.email = "invalid-email"
        sut.password = "123456"
        #expect(!sut.isLoginButtonEnabled)

        sut.email = "teste@teste.com"
        #expect(sut.isLoginButtonEnabled)
    }

    @Test
    func successfulLoginAuthenticatesPersistsTracksAndUpdatesSession() async {
        let context = makeSUT()
        context.sut.email = "teste@teste.com"
        context.sut.password = "123456"

        await context.sut.login()

        #expect(context.auth.receivedEmail == "teste@teste.com")
        #expect(context.auth.receivedPassword == "123456")
        #expect(context.userRepository.savedUsers == [.fixture])
        #expect(context.session.currentUser == .fixture)
        #expect(context.analytics.trackedEvents.map(\.name) == ["login_success"])
        #expect(context.analytics.trackedEvents.first?.parameters["user_id"] as? String == "user-id")
        #expect(context.analytics.trackedEvents.first?.parameters["provider"] as? String == "firebase_auth")
        #expect(context.crashlytics.recordedErrors.isEmpty)
        #expect(context.sut.errorMessage == nil)
        #expect(!context.sut.isLoading)
    }

    @Test
    func authenticationFailureShowsErrorAndRecordsCrashlytics() async {
        let context = makeSUT()
        context.auth.signInResult = .failure(TestError.expected)
        context.sut.email = "teste@teste.com"
        context.sut.password = "123456"

        await context.sut.login()

        #expect(context.sut.errorMessage == L10n.loginError)
        #expect(context.userRepository.savedUsers.isEmpty)
        #expect(context.session.currentUser == nil)
        #expect(context.analytics.trackedEvents.isEmpty)
        #expect(context.crashlytics.recordedErrors.count == 1)
        #expect(context.crashlytics.recordedContexts.first?["screen"] == "login")
        #expect(context.crashlytics.recordedContexts.first?["action"] == "firebase_auth_sign_in")
    }

    @Test
    func persistenceFailureDoesNotUpdateSessionOrTrackSuccess() async {
        let context = makeSUT()
        context.userRepository.saveError = TestError.expected
        context.sut.email = "teste@teste.com"
        context.sut.password = "123456"

        await context.sut.login()

        #expect(context.session.currentUser == nil)
        #expect(context.analytics.trackedEvents.isEmpty)
        #expect(context.crashlytics.recordedErrors.count == 1)
        #expect(context.crashlytics.recordedContexts.first?["action"] == "firebase_auth_sign_in")
    }

    private func makeSUT() -> Context {
        let auth = MockAuthService()
        let analytics = MockAnalyticsService()
        let crashlytics = MockCrashlyticsService()
        let userRepository = MockUserRepository()
        let session = AppSession()
        session.setLoggedOut()

        let sut = LoginViewModel(
            authService: auth,
            analyticsService: analytics,
            crashlyticsService: crashlytics,
            userRepository: userRepository,
            session: session
        )

        return Context(
            sut: sut,
            auth: auth,
            analytics: analytics,
            crashlytics: crashlytics,
            userRepository: userRepository,
            session: session
        )
    }

    private struct Context {
        let sut: LoginViewModel
        let auth: MockAuthService
        let analytics: MockAnalyticsService
        let crashlytics: MockCrashlyticsService
        let userRepository: MockUserRepository
        let session: AppSession
    }
}
