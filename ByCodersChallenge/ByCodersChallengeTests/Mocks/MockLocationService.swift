//
//  MockLocationService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

@testable import ByCodersChallenge

@MainActor
final class MockLocationService: LocationService {
    var result: Result<UserLocation, Error> = .success(.fixture)
    private(set) var requestAuthorizationCallCount = 0
    private(set) var currentLocationCallCount = 0

    func requestAuthorization() async {
        requestAuthorizationCallCount += 1
    }

    func currentLocation() async throws -> UserLocation {
        currentLocationCallCount += 1
        return try result.get()
    }
}

extension UserLocation {
    static let fixture = UserLocation(latitude: -23.5505, longitude: -46.6333)
}
