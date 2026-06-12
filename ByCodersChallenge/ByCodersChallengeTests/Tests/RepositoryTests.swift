
import Foundation
import SwiftData
import Testing
@testable import ByCodersChallenge

@MainActor
struct RepositoryTests {
    @Test
    func userRepositorySavesAndFetchesLoggedUser() async throws {
        let context = try makeContext()

        try await context.userRepository.saveLoggedUser(.fixture)

        #expect(try await context.userRepository.loggedUser() == .fixture)
    }

    @Test
    func userRepositoryUpdatesExistingUserWithoutCreatingDuplicate() async throws {
        let context = try makeContext()
        let updatedUser = AuthenticatedUser(
            id: AuthenticatedUser.fixture.id,
            email: "updated@teste.com",
            displayName: "Updated User"
        )

        try await context.userRepository.saveLoggedUser(.fixture)
        try await context.userRepository.saveLoggedUser(updatedUser)

        let entities = try context.modelContext.fetch(FetchDescriptor<LoggedUserEntity>())
        #expect(entities.count == 1)
        #expect(try await context.userRepository.loggedUser() == updatedUser)
    }

    @Test
    func userRepositoryReturnsMostRecentlyLoggedUser() async throws {
        let context = try makeContext()
        let olderUser = LoggedUserEntity(
            id: "older-user",
            email: "older@teste.com",
            displayName: "Older User",
            loggedAt: .distantPast
        )
        let recentUser = LoggedUserEntity(
            id: "recent-user",
            email: "recent@teste.com",
            displayName: "Recent User",
            loggedAt: .now
        )
        context.modelContext.insert(olderUser)
        context.modelContext.insert(recentUser)
        try context.modelContext.save()

        let result = try await context.userRepository.loggedUser()

        #expect(result == AuthenticatedUser(
            id: recentUser.id,
            email: recentUser.email,
            displayName: recentUser.displayName
        ))
    }

    @Test
    func userRepositoryDeletesEveryPersistedUser() async throws {
        let context = try makeContext()
        context.modelContext.insert(LoggedUserEntity(
            id: "first",
            email: nil,
            displayName: nil
        ))
        context.modelContext.insert(LoggedUserEntity(
            id: "second",
            email: nil,
            displayName: nil
        ))
        try context.modelContext.save()

        try await context.userRepository.deleteLoggedUser()

        let entities = try context.modelContext.fetch(FetchDescriptor<LoggedUserEntity>())
        #expect(entities.isEmpty)
        #expect(try await context.userRepository.loggedUser() == nil)
    }

    @Test
    func locationRepositoryUpdatesSingleLastLocation() async throws {
        let context = try makeContext()
        let first = UserLocation(latitude: -23.5505, longitude: -46.6333)
        let latest = UserLocation(latitude: 40.7128, longitude: -74.0060)

        try await context.locationRepository.saveLastLocation(first)
        try await context.locationRepository.saveLastLocation(latest)

        let entities = try context.modelContext.fetch(FetchDescriptor<LastLocationEntity>())
        #expect(entities.count == 1)
        #expect(entities.first?.latitude == latest.latitude)
        #expect(entities.first?.longitude == latest.longitude)
    }

    @Test
    func locationRepositoryRefreshesTimestampWhenUpdatingExistingLocation() async throws {
        let context = try makeContext()
        let staleEntity = LastLocationEntity(
            latitude: -23.5505,
            longitude: -46.6333,
            updatedAt: .distantPast
        )
        context.modelContext.insert(staleEntity)
        try context.modelContext.save()

        try await context.locationRepository.saveLastLocation(
            UserLocation(latitude: 40.7128, longitude: -74.0060)
        )

        let entities = try context.modelContext.fetch(FetchDescriptor<LastLocationEntity>())
        #expect(entities.count == 1)
        #expect(entities.first?.updatedAt != .distantPast)
    }

    @Test
    func locationRepositoryFetchesNilWhenNoLocationWasSaved() async throws {
        let context = try makeContext()

        #expect(try await context.locationRepository.fetchLastLocation() == nil)
    }

    @Test
    func locationRepositoryFetchesPreviouslySavedLocation() async throws {
        let context = try makeContext()
        let location = UserLocation(latitude: -23.5505, longitude: -46.6333)

        try await context.locationRepository.saveLastLocation(location)

        #expect(try await context.locationRepository.fetchLastLocation() == location)
    }

    @Test
    func locationRepositoryFetchesMostRecentlyUpdatedLocation() async throws {
        let context = try makeContext()
        context.modelContext.insert(LastLocationEntity(
            latitude: 1,
            longitude: 1,
            updatedAt: .distantPast
        ))
        context.modelContext.insert(LastLocationEntity(
            latitude: -23.5505,
            longitude: -46.6333,
            updatedAt: .now
        ))
        try context.modelContext.save()

        let result = try await context.locationRepository.fetchLastLocation()

        #expect(result == UserLocation(latitude: -23.5505, longitude: -46.6333))
    }

    @Test
    func locationRepositoryDeletesEveryPersistedLocation() async throws {
        let context = try makeContext()
        context.modelContext.insert(LastLocationEntity(latitude: 1, longitude: 1))
        context.modelContext.insert(LastLocationEntity(latitude: 2, longitude: 2))
        try context.modelContext.save()

        try await context.locationRepository.deleteLastLocation()

        let entities = try context.modelContext.fetch(FetchDescriptor<LastLocationEntity>())
        #expect(entities.isEmpty)
        #expect(try await context.locationRepository.fetchLastLocation() == nil)
    }

    @Test
    func locationRepositoryDeleteIsANoOpWhenNothingWasSaved() async throws {
        let context = try makeContext()

        try await context.locationRepository.deleteLastLocation()

        #expect(try await context.locationRepository.fetchLastLocation() == nil)
    }

    private func makeContext() throws -> Context {
        let modelContainer = try LocalDatabase.makeModelContainer(inMemory: true)
        let modelContext = modelContainer.mainContext

        return Context(
            modelContainer: modelContainer,
            modelContext: modelContext,
            userRepository: SwiftDataUserRepository(modelContext: modelContext),
            locationRepository: SwiftDataLocationRepository(modelContext: modelContext)
        )
    }

    private struct Context {
        let modelContainer: ModelContainer
        let modelContext: ModelContext
        let userRepository: SwiftDataUserRepository
        let locationRepository: SwiftDataLocationRepository
    }
}
