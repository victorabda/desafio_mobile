//
//  FirebaseConfig.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseCore
import Foundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // UI test scenarios run fully offline against fakes, so Firebase is
        // only configured for real (and unit-test) launches.
        if UITestScenario.current == nil {
            FirebaseApp.configure()
        }
        return true
    }
}
