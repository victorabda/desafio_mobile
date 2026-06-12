//
//  AnalyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

/// Analytics boundary: events are strongly typed (`AnalyticsEvent`) so names
/// and parameters are defined once, not scattered as string literals.
protocol AnalyticsService {
    func track(_ event: AnalyticsEvent)
}
