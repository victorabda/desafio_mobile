//
//  MockCrashlyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

@testable import ByCodersChallenge

@MainActor
final class MockCrashlyticsService: CrashlyticsService {
    private(set) var recordedErrors: [Error] = []
    private(set) var recordedContexts: [[String: String]] = []

    func record(error: Error, context: [String: String]) {
        recordedErrors.append(error)
        recordedContexts.append(context)
    }
}
