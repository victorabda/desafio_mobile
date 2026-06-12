//
//  CoreLocationServiceTests.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import CoreLocation
import Testing
@testable import ByCodersChallenge

@MainActor
struct CoreLocationServiceTests {
    @Test
    func requestAuthorizationReturnsImmediatelyWhenAlreadyDetermined() async {
        let context = makeSUT(status: .denied)

        await context.sut.requestAuthorization()

        #expect(context.manager.requestWhenInUseAuthorizationCallCount == 0)
    }

    @Test
    func requestAuthorizationAwaitsAuthorizationChangeCallback() async {
        let context = makeSUT(status: .notDetermined)
        context.manager.onRequestWhenInUseAuthorization = {
            // First callback still undetermined must keep the request pending.
            context.sut.handleAuthorizationChange()
            context.manager.authorizationStatus = .authorizedWhenInUse
            context.sut.locationManagerDidChangeAuthorization(CLLocationManager())
        }

        await context.sut.requestAuthorization()

        #expect(context.manager.requestWhenInUseAuthorizationCallCount == 1)
    }

    @Test
    func currentLocationThrowsPermissionDeniedWhenNotAuthorized() async {
        for status in [CLAuthorizationStatus.notDetermined, .denied, .restricted] {
            let context = makeSUT(status: status)

            await #expect(throws: LocationError.permissionDenied) {
                try await context.sut.currentLocation()
            }
            #expect(context.manager.requestLocationCallCount == 0)
        }
    }

    @Test
    func currentLocationDeliversLocationReportedByManager() async throws {
        let context = makeSUT(status: .authorizedWhenInUse)
        context.manager.onRequestLocation = {
            context.sut.locationManager(CLLocationManager(), didUpdateLocations: [
                CLLocation(latitude: -23.5505, longitude: -46.6333)
            ])
        }

        let location = try await context.sut.currentLocation()

        #expect(location == UserLocation(latitude: -23.5505, longitude: -46.6333))
        #expect(context.manager.requestLocationCallCount == 1)
    }

    @Test
    func currentLocationThrowsUnavailableWhenManagerReportsNoLocations() async {
        let context = makeSUT(status: .authorizedAlways)
        context.manager.onRequestLocation = {
            context.sut.locationManager(CLLocationManager(), didUpdateLocations: [])
        }

        await #expect(throws: LocationError.unavailable) {
            try await context.sut.currentLocation()
        }
    }

    @Test
    func currentLocationMapsDeniedManagerFailureToPermissionDenied() async {
        let context = makeSUT(status: .authorizedWhenInUse)
        context.manager.onRequestLocation = {
            context.sut.locationManager(
                CLLocationManager(),
                didFailWithError: CLError(.denied)
            )
        }

        await #expect(throws: LocationError.permissionDenied) {
            try await context.sut.currentLocation()
        }
    }

    @Test
    func currentLocationPropagatesUnexpectedManagerFailure() async {
        let context = makeSUT(status: .authorizedWhenInUse)
        context.manager.onRequestLocation = {
            context.sut.locationManager(
                CLLocationManager(),
                didFailWithError: TestError.expected
            )
        }

        await #expect(throws: TestError.expected) {
            try await context.sut.currentLocation()
        }
    }

    @Test
    func concurrentCallsShareSingleInFlightLocationRequest() async throws {
        let context = makeSUT(status: .authorizedWhenInUse)

        let first = Task { try await context.sut.currentLocation() }
        let second = Task { try await context.sut.currentLocation() }
        await yieldUntil { context.manager.requestLocationCallCount >= 1 }

        context.sut.handleLocationUpdate([
            CLLocation(latitude: -23.5505, longitude: -46.6333)
        ])

        #expect(try await first.value == .fixture)
        #expect(try await second.value == .fixture)
        #expect(context.manager.requestLocationCallCount == 1)
    }

    @Test
    func newRequestStartsAfterPreviousOneFinishes() async throws {
        let context = makeSUT(status: .authorizedWhenInUse)
        context.manager.onRequestLocation = {
            context.sut.handleLocationUpdate([
                CLLocation(latitude: -23.5505, longitude: -46.6333)
            ])
        }

        _ = try await context.sut.currentLocation()
        _ = try await context.sut.currentLocation()

        #expect(context.manager.requestLocationCallCount == 2)
    }

    private func makeSUT(status: CLAuthorizationStatus) -> Context {
        let manager = MockLocationManager()
        manager.authorizationStatus = status

        return Context(
            sut: CoreLocationService(manager: manager),
            manager: manager
        )
    }

    private func yieldUntil(
        attempts: Int = 100,
        _ condition: () -> Bool
    ) async {
        for _ in 0..<attempts where !condition() {
            await Task.yield()
        }
    }

    private struct Context {
        let sut: CoreLocationService
        let manager: MockLocationManager
    }
}
