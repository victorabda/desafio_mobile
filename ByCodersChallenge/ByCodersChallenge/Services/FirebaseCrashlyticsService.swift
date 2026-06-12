//
//  FirebaseCrashlyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseCrashlytics

final class FirebaseCrashlyticsService: CrashlyticsService {
    func record(error: Error, context: [String: String]) {
        // userInfo attaches the keys to this event only; setCustomValue would
        // leak the context into every report recorded later in the session.
        Crashlytics.crashlytics().record(error: error, userInfo: context)
    }
}
