//
//  LoggedUserEntity.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftData
import Foundation

/// SwiftData row for the authenticated user, keyed by the auth provider's id
/// so repeated logins update in place. `loggedAt` orders session restoration.
@Model
final class LoggedUserEntity {
    @Attribute(.unique) var id: String
    var email: String?
    var displayName: String?
    var loggedAt: Date

    init(id: String, email: String?, displayName: String?, loggedAt: Date = .now) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.loggedAt = loggedAt
    }
}
