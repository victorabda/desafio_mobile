//
//  ByCodersChallengeApp.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftUI

struct AppRootView: View {
    @ObservedObject var session: AppSession
    let container: AppContainer

    var body: some View {
        switch session.authState {
        case .restoring:
            ProgressView("session.restoring")
                .task {
                    await container.restoreSession()
                }

        case .loggedOut:
            LoginView(viewModel: container.makeLoginViewModel())

        case .loggedIn:
            NavigationStack {
                HomeView(viewModel: container.makeHomeViewModel())
            }
        }
    }
}
