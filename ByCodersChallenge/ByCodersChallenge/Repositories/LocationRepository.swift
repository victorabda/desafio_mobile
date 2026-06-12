//
//  LocationRepository.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation
import SwiftData

/// Persistence boundary for the user's last known position. Reading it back
/// powers the stale-location fallback on the Home screen when GPS fails.
protocol LocationRepository {
    func saveLastLocation(_ location: UserLocation) async throws
    func fetchLastLocation() async throws -> UserLocation?
    func deleteLastLocation() async throws
}

@MainActor
final class SwiftDataLocationRepository: LocationRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Single-row upsert: the table is meant to hold exactly one "last
    /// location", so updates rewrite the existing record in place.
    func saveLastLocation(_ location: UserLocation) async throws {
        let descriptor = FetchDescriptor<LastLocationEntity>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        if let entity = try modelContext.fetch(descriptor).first {
            entity.latitude = location.latitude
            entity.longitude = location.longitude
            entity.updatedAt = .now
        } else {
            modelContext.insert(LastLocationEntity(
                latitude: location.latitude,
                longitude: location.longitude
            ))
        }

        try modelContext.save()
    }

    func fetchLastLocation() async throws -> UserLocation? {
        let descriptor = FetchDescriptor<LastLocationEntity>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return UserLocation(latitude: entity.latitude, longitude: entity.longitude)
    }

    /// Removes every persisted location (location is personal data, so it is
    /// wiped together with the session on logout).
    func deleteLastLocation() async throws {
        let locations = try modelContext.fetch(FetchDescriptor<LastLocationEntity>())
        locations.forEach(modelContext.delete)
        try modelContext.save()
    }
}
