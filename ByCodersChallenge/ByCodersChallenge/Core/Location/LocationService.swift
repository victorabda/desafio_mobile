//
//  LocationService.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import CoreLocation

protocol LocationService {
    func requestAuthorization() async
    func currentLocation() async throws -> UserLocation
}

@MainActor
final class CoreLocationService: NSObject, LocationService, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<Void, Never>?
    private var locationContinuation: CheckedContinuation<UserLocation, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

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

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation?.resume(throwing: CancellationError())
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        authorizationContinuation?.resume()
        authorizationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let locationError = error as? CLError, locationError.code == .denied {
            locationContinuation?.resume(throwing: LocationError.permissionDenied)
        } else {
            locationContinuation?.resume(throwing: error)
        }
        locationContinuation = nil
    }
}
