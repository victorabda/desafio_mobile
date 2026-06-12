//
//  FirebaseAnalyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import FirebaseAnalytics

final class FirebaseAnalyticsService: AnalyticsService {
    func track(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}
