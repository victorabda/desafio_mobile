//
//  CrashlyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

/// Error-reporting boundary. `context` carries screen/action metadata so each
/// non-fatal report is searchable by where it happened, not just by its type.
protocol CrashlyticsService {
    func record(error: Error, context: [String: String])
}
