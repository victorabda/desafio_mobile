//
//  LocationPermissionStatus.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation

// These are pure value types: `nonisolated` opts them out of the target's
// default MainActor isolation so their synthesized conformances (Equatable)
// stay usable from any concurrency context.

/// Framework-agnostic projection of `CLAuthorizationStatus`, collapsing the
/// "always"/"when in use" variants the app does not distinguish between.
nonisolated enum LocationPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
}

/// Domain errors for location access. `permissionDenied` is handled as a
/// dedicated UI state (not a generic failure), so it is deliberately separate
/// from `unavailable`.
nonisolated enum LocationError: LocalizedError {
    case permissionDenied
    case unavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            String(localized: "location.permission.denied")
        case .unavailable:
            String(localized: "location.unavailable")
        }
    }
}

/// Value-type coordinate used across ViewModels and persistence, keeping
/// `CoreLocation` types confined to the service layer.
nonisolated struct UserLocation: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
}
