//
//  UserLocationMapView.swift
//  ByCodersChallenge
//
//  Created by Victor Almeida on 11/06/26.
//

import CoreLocation
import MapKit
import SwiftUI

struct UserLocationMapView: View {
    let location: UserLocation

    @State private var position: MapCameraPosition
    @State private var hasMovedAway = false

    init(location: UserLocation) {
        self.location = location
        _position = State(initialValue: .region(Self.region(for: location)))
    }

    var body: some View {
        Map(position: $position) {
            Marker("map.user_location", coordinate: coordinate)
                .tint(.blue)
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            let center = CLLocation(
                latitude: context.region.center.latitude,
                longitude: context.region.center.longitude
            )
            let userLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )

            hasMovedAway = center.distance(from: userLocation) > 75
        }
        .overlay(alignment: .bottomTrailing) {
            if hasMovedAway {
                Button(action: recenter) {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .frame(width: 48, height: 48)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .padding()
                .accessibilityLabel(Text("map.recenter"))
                .accessibilityIdentifier("home_recenter_button")
            }
        }
    }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }

    private func recenter() {
        withAnimation {
            position = .region(Self.region(for: location))
            hasMovedAway = false
        }
    }

    private static func region(for location: UserLocation) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

#Preview("Mapa - São Paulo") {
    UserLocationMapView(
        location: UserLocation(latitude: -23.5505, longitude: -46.6333)
    )
}
