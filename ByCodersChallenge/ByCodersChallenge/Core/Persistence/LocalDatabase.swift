//
//  LocalDatabase.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftData

enum LocalDatabase {
    /// Builds the SwiftData container for the app's offline schema. `inMemory`
    /// backs the same schema with volatile storage for tests and UI-test
    /// scenarios, keeping runs hermetic.
    static func makeModelContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            LoggedUserEntity.self,
            LastLocationEntity.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
