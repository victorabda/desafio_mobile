//
//  LocalDatabase.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftData

enum LocalDatabase {
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
