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
    
    // Buffer per smoothing altitudine
    private var altitudeBuffer: [Double] = []
    private let maxBufferSize = 5  // media sugli ultimi 5 valori

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func startTracking(onUpdate: @escaping (HikeLocation) -> Void) {
        self.onUpdate = onUpdate
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
        altitudeBuffer.removeAll()
        onUpdate = nil
    }
    
    /// Calcola la media mobile dell'altitudine
    private func smoothedAltitude(newAltitude: Double) -> Double {
        altitudeBuffer.append(newAltitude)
        if altitudeBuffer.count > maxBufferSize {
            altitudeBuffer.removeFirst()
        }
        return altitudeBuffer.reduce(0, +) / Double(altitudeBuffer.count)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
                    
                    // Filtraggio qualità GPS (orizzontale)
                    guard location.horizontalAccuracy > 0,
                          location.horizontalAccuracy < 20,
                          abs(location.timestamp.timeIntervalSinceNow) < 10
                    else { continue }
                    
                    // Filtraggio altitudine
                    guard location.verticalAccuracy > 0,
                          location.verticalAccuracy < 15
                    else { continue }
                    
                    // Scartiamo velocità improbabili
                    if location.speed > 10 { continue }
                    
                    // Applica smoothing all'altitudine
                    let smoothedAlt = smoothedAltitude(newAltitude: location.altitude)
            
            let hikeLocation = HikeLocation(
                coordinate: location.coordinate,
                altitude: location.altitude,
                horizontalAccuracy: location.horizontalAccuracy,
                verticalAccuracy: location.verticalAccuracy,
                timestamp: location.timestamp,
                location: CLLocation(coordinate: location.coordinate,
                                     altitude: smoothedAlt,
                                     horizontalAccuracy: location.horizontalAccuracy,
                                     verticalAccuracy: location.verticalAccuracy,
                                     timestamp: location.timestamp)
            )
                    
            onUpdate?(hikeLocation)
                }
        
    }
}
