//
//  FirebaseCrashlyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseCrashlytics

final class FirebaseCrashlyticsService: CrashlyticsService {
    func record(error: Error, context: [String: String]) {
        let crashlytics = Crashlytics.crashlytics()

        context.forEach { key, value in
            crashlytics.setCustomValue(value, forKey: key)
        }

        crashlytics.record(error: error)
    }
}
