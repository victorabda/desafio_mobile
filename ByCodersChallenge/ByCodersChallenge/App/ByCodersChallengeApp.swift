//
//  ByCodersChallengeApp.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftUI
import SwiftData

@main
struct ByCodersChallengeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var session: AppSession

    private let container: AppContainer

    init() {
        let container = AppContainer()
        self.container = container
        _session = StateObject(wrappedValue: container.session)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(session: session, container: container)
        }
        .modelContainer(container.modelContainer)
    }
}
