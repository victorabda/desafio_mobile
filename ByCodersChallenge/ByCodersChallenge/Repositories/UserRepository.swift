//
//  UserRepository.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation
import SwiftData

/// Persistence boundary for the logged user (the challenge's offline-storage
/// requirement, implemented with SwiftData instead of WatermelonDB).
protocol UserRepository {
    func saveLoggedUser(_ user: AuthenticatedUser) async throws
    func loggedUser() async throws -> AuthenticatedUser?
    func deleteLoggedUser() async throws
}

@MainActor
final class SwiftDataUserRepository: UserRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Upsert keyed by the auth provider's user id: signing in again with the
    /// same account refreshes the row instead of accumulating duplicates.
    func saveLoggedUser(_ user: AuthenticatedUser) async throws {
        let userId = user.id
        let descriptor = FetchDescriptor<LoggedUserEntity>(
            predicate: #Predicate { $0.id == userId }
        )

        if let entity = try modelContext.fetch(descriptor).first {
            entity.email = user.email
            entity.displayName = user.displayName
            entity.loggedAt = .now
        } else {
            modelContext.insert(LoggedUserEntity(
                id: user.id,
                email: user.email,
                displayName: user.displayName
            ))
        }

        try modelContext.save()
    }

    /// Most recent login wins if more than one row ever exists, making
    /// session restoration deterministic.
    func loggedUser() async throws -> AuthenticatedUser? {
        let descriptor = FetchDescriptor<LoggedUserEntity>(
            sortBy: [SortDescriptor(\.loggedAt, order: .reverse)]
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return AuthenticatedUser(
            id: entity.id,
            email: entity.email,
            displayName: entity.displayName
        )
    }

    func deleteLoggedUser() async throws {
        let users = try modelContext.fetch(FetchDescriptor<LoggedUserEntity>())
        users.forEach(modelContext.delete)
        try modelContext.save()
    }
}
