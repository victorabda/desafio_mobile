//
//  LastLocationEntity.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import SwiftData
import Foundation

@Model
final class LastLocationEntity {
    var latitude: Double
    var longitude: Double
    var updatedAt: Date

    init(latitude: Double, longitude: Double, updatedAt: Date = .now) {
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAt
    }
}
