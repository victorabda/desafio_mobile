@testable import ByCodersChallenge

@MainActor
final class MockUserRepository: UserRepository {
    var loggedUserResult: Result<AuthenticatedUser?, Error> = .success(nil)
    var saveError: Error?
    var deleteError: Error?
    private(set) var savedUsers: [AuthenticatedUser] = []
    private(set) var loggedUserCallCount = 0
    private(set) var deleteCallCount = 0

    func saveLoggedUser(_ user: AuthenticatedUser) async throws {
        if let saveError {
            throw saveError
        }
        savedUsers.append(user)
    }

    func loggedUser() async throws -> AuthenticatedUser? {
        loggedUserCallCount += 1
        return try loggedUserResult.get()
    }

    func deleteLoggedUser() async throws {
        deleteCallCount += 1
        if let deleteError {
            throw deleteError
        }
    }
}

@MainActor
final class MockLocationRepository: LocationRepository {
    var saveError: Error?
    var deleteError: Error?
    var fetchLastLocationResult: Result<UserLocation?, Error> = .success(nil)
    private(set) var savedLocations: [UserLocation] = []
    private(set) var fetchLastLocationCallCount = 0
    private(set) var deleteCallCount = 0

    func saveLastLocation(_ location: UserLocation) async throws {
        if let saveError {
            throw saveError
        }
        savedLocations.append(location)
    }

    func fetchLastLocation() async throws -> UserLocation? {
        fetchLastLocationCallCount += 1
        return try fetchLastLocationResult.get()
    }

    func deleteLastLocation() async throws {
        deleteCallCount += 1
        if let deleteError {
            throw deleteError
        }
    }
}
