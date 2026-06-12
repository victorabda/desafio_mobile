//
//  AnalyticsTracking.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

enum AnalyticsEvent {
    case loginSuccess(userId: String, provider: String)
    case homeRendered(userId: String, latitude: Double, longitude: Double)

    var name: String {
        switch self {
        case .loginSuccess:
            "login_success"
        case .homeRendered:
            "home_rendered"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case let .loginSuccess(userId, provider):
            [
                "user_id": userId,
                "provider": provider
            ]
        case let .homeRendered(userId, latitude, longitude):
            [
                "user_id": userId,
                "latitude": latitude,
                "longitude": longitude
            ]
        }
    }
}
