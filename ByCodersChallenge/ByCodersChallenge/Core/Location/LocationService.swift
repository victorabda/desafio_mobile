//
//  LocationService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import CoreLocation

/// async/await facade over location access, so callers never deal with
/// delegates or callback-based APIs.
protocol LocationService {
    func requestAuthorization() async
    func currentLocation() async throws -> UserLocation
}

/// Seam over `CLLocationManager` that allows unit tests to drive
/// authorization status and location delivery deterministically.
protocol LocationManaging: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestWhenInUseAuthorization()
    func requestLocation()
}

extension CLLocationManager: LocationManaging {}

/// Bridges `CLLocationManager`'s delegate callbacks to structured concurrency
/// using checked continuations. Isolated to the main actor, matching the run
/// loop the manager is created on.
@MainActor
final class CoreLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    private let manager: LocationManaging
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    private var locationContinuation: CheckedContinuation<UserLocation, Error>?
    private var inFlightLocationTask: Task<UserLocation, Error>?

    init(manager: LocationManaging) {
        self.manager = manager
        super.init()
    }

    override convenience init() {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.init(manager: manager)
        manager.delegate = self
    }

    /// Suspends until the user answers the permission prompt; resumes via
    /// `locationManagerDidChangeAuthorization`. No-op when already determined.
    func requestAuthorization() async {
        guard manager.authorizationStatus == .notDetermined else { return }

        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    func currentLocation() async throws -> UserLocation {
        guard manager.authorizationStatus == .authorizedAlways
                || manager.authorizationStatus == .authorizedWhenInUse else {
            throw LocationError.permissionDenied
        }

        // Concurrent calls (e.g. .task racing onChange(scenePhase)) share the
        // in-flight request instead of cancelling each other's continuation.
        if let inFlightLocationTask {
            return try await inFlightLocationTask.value
        }

        let task = Task<UserLocation, Error> {
            try await withCheckedThrowingContinuation { continuation in
                locationContinuation = continuation
                manager.requestLocation()
            }
        }
        inFlightLocationTask = task
        defer { inFlightLocationTask = nil }

        return try await task.value
    }

    // MARK: - CLLocationManagerDelegate
    // Thin forwarders into internal handlers, which hold the actual logic and
    // are directly exercisable by unit tests.

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        handleLocationUpdate(locations)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationChange()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleLocationFailure(error)
    }

    func handleLocationUpdate(_ locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            locationContinuation?.resume(throwing: LocationError.unavailable)
            locationContinuation = nil
            return
        }

        locationContinuation?.resume(returning: UserLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        ))
        locationContinuation = nil
    }

    func handleAuthorizationChange() {
        guard manager.authorizationStatus != .notDetermined else { return }
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    func handleLocationFailure(_ error: Error) {
        // CLError.denied means the permission was revoked mid-request; map it
        // to the domain error so the UI shows the permission flow, not a
        // generic failure.
        if let locationError = error as? CLError, locationError.code == .denied {
            locationContinuation?.resume(throwing: LocationError.permissionDenied)
        } else {
            locationContinuation?.resume(throwing: error)
        }
        locationContinuation = nil
    }
}
