//
//  LocationModelsTests.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation
import Testing
@testable import ByCodersChallenge

struct LocationModelsTests {
    @Test
    func locationErrorsProvideDistinctLocalizedDescriptions() {
        let permissionDenied = LocationError.permissionDenied.errorDescription
        let unavailable = LocationError.unavailable.errorDescription

        #expect(permissionDenied?.isEmpty == false)
        #expect(unavailable?.isEmpty == false)
        #expect(permissionDenied != unavailable)
    }

    @Test
    func locationErrorLocalizedDescriptionMatchesErrorDescription() {
        let error: Error = LocationError.permissionDenied

        #expect(error.localizedDescription == LocationError.permissionDenied.errorDescription)
    }

    @Test
    func userLocationEqualityComparesCoordinates() {
        let location = UserLocation(latitude: -23.5505, longitude: -46.6333)

        #expect(location == UserLocation(latitude: -23.5505, longitude: -46.6333))
        #expect(location != UserLocation(latitude: -23.5505, longitude: -46.6334))
        #expect(location != UserLocation(latitude: -23.5506, longitude: -46.6333))
    }

    @Test
    func locationPermissionStatusDistinguishesEveryCase() {
        let statuses: [LocationPermissionStatus] = [.notDetermined, .authorized, .denied]

        #expect(Set(statuses.map(String.init(describing:))).count == statuses.count)
        #expect(LocationPermissionStatus.authorized != .denied)
    }
}
