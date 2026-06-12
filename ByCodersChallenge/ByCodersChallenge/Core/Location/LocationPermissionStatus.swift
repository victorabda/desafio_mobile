//
//  LocationPermissionStatus.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import Foundation

enum LocationPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
}

enum LocationError: LocalizedError {
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

struct UserLocation: Equatable, Sendable {
    let latitude: Double
    let longitude: Double
}
