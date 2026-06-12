//
//  LoginViewModel.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Combine
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let authService: AuthService
    private let analyticsService: AnalyticsService
    private let crashlyticsService: CrashlyticsService
    private let userRepository: UserRepository
    private let session: AppSession

    init(
        authService: AuthService,
        analyticsService: AnalyticsService,
        crashlyticsService: CrashlyticsService,
        userRepository: UserRepository,
        session: AppSession
    ) {
        self.authService = authService
        self.analyticsService = analyticsService
        self.crashlyticsService = crashlyticsService
        self.userRepository = userRepository
        self.session = session
    }

    var isLoginButtonEnabled: Bool {
        LoginCredentials(email: email, password: password).isValid && !isLoading
    }

    /// Authenticates, persists the user locally and only then publishes the
    /// logged-in session — guaranteeing that whenever the app shows Home, the
    /// user is also recoverable offline on the next launch. The success
    /// analytics event is tracked after the whole flow commits.
    func login() async {
        guard isLoginButtonEnabled else { return }

        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.signIn(email: email, password: password)

            try await userRepository.saveLoggedUser(user)

            session.setLoggedInUser(user)

            analyticsService.track(.loginSuccess(
                userId: user.id,
                provider: "firebase_auth"
            ))
        } catch {
            errorMessage = L10n.loginError

            crashlyticsService.record(error: error, context: [
                "screen": "login",
                "action": "firebase_auth_sign_in"
            ])
        }

        isLoading = false
    }
}
