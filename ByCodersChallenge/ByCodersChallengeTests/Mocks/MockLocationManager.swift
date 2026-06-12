//
//  MockLocationManager.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import CoreLocation
@testable import ByCodersChallenge

@MainActor
final class MockLocationManager: LocationManaging {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var onRequestWhenInUseAuthorization: (() -> Void)?
    var onRequestLocation: (() -> Void)?
    private(set) var requestWhenInUseAuthorizationCallCount = 0
    private(set) var requestLocationCallCount = 0

    func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCallCount += 1
        onRequestWhenInUseAuthorization?()
    }

    func requestLocation() {
        requestLocationCallCount += 1
        onRequestLocation?()
    }
}
