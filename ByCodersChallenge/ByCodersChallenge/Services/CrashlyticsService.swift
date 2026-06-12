//
//  CrashlyticsService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

protocol CrashlyticsService {
    func record(error: Error, context: [String: String])
}
