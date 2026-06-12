//
//  MockAnalyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

@testable import ByCodersChallenge

@MainActor
final class MockAnalyticsService: AnalyticsService {
    private(set) var trackedEvents: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }
}
