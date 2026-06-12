//
//  LocationRepository.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation
import SwiftData

protocol LocationRepository {
    func saveLastLocation(_ location: UserLocation) async throws
}

@MainActor
final class SwiftDataLocationRepository: LocationRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

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
}
