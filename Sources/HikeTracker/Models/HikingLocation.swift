//
//  HikingLocation.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import Foundation
import CoreLocation

public struct HikingLocation: Sendable {
    public let coordinate: CLLocationCoordinate2D
    public let altitude: Double
    public let horizontalAccuracy: Double
    public let verticalAccuracy: Double
    public let timestamp: Date
    public let speed: Double
    public let course: Double
    
    public init(from location: CLLocation) {
        self.coordinate = location.coordinate
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.course = location.course
    }
    
    public init(from location: CLLocation, altitude smoothedAltitude: Double) {
        self.coordinate = location.coordinate
        self.altitude = smoothedAltitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.course = location.course
    }
}

