//
//  LocationService.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 09/09/25.
//

import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var onUpdate: ((HikeLocation) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func startTracking(onUpdate: @escaping (HikeLocation) -> Void) {
        self.onUpdate = onUpdate
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        onUpdate = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        let hikeLocation = HikeLocation(
            coordinate: last.coordinate,
            altitude: last.altitude,
            horizontalAccuracy: last.horizontalAccuracy,
            verticalAccuracy: last.verticalAccuracy,
            timestamp: last.timestamp
        )
        onUpdate?(hikeLocation)
    }
}
