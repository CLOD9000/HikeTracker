//
//  HikingLocationConfiguration.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import CoreLocation

public struct HikingLocationConfiguration: Sendable {
    public let desiredAccuracy: CLLocationAccuracy
    public let distanceFilter: CLLocationDistance
    public let maxHorizontalAccuracy: Double
    public let maxVerticalAccuracy: Double
    public let minTimeBetweenUpdates: TimeInterval
    public let backgroundLocationUpdates: Bool
    
    public static let hiking = HikingLocationConfiguration(
        desiredAccuracy: kCLLocationAccuracyBest,
        distanceFilter: 5.0,
        maxHorizontalAccuracy: 20.0,
        maxVerticalAccuracy: 50.0,
        minTimeBetweenUpdates: 3.0,
        backgroundLocationUpdates: true
    )
    
    public static let precise = HikingLocationConfiguration(
        desiredAccuracy: kCLLocationAccuracyBestForNavigation,
        distanceFilter: 2.0,
        maxHorizontalAccuracy: 10.0,
        maxVerticalAccuracy: 30.0,
        minTimeBetweenUpdates: 2.0,
        backgroundLocationUpdates: true
    )
    
    public static let batterySaver = HikingLocationConfiguration(
        desiredAccuracy: kCLLocationAccuracyNearestTenMeters,
        distanceFilter: 10.0,
        maxHorizontalAccuracy: 50.0,
        maxVerticalAccuracy: 100.0,
        minTimeBetweenUpdates: 10.0,
        backgroundLocationUpdates: true
    )
    
    public init(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
               distanceFilter: CLLocationDistance = 5.0,
               maxHorizontalAccuracy: Double = 20.0,
               maxVerticalAccuracy: Double = 50.0,
               minTimeBetweenUpdates: TimeInterval = 3.0,
               backgroundLocationUpdates: Bool = true) {
        self.desiredAccuracy = desiredAccuracy
        self.distanceFilter = distanceFilter
        self.maxHorizontalAccuracy = maxHorizontalAccuracy
        self.maxVerticalAccuracy = maxVerticalAccuracy
        self.minTimeBetweenUpdates = minTimeBetweenUpdates
        self.backgroundLocationUpdates = backgroundLocationUpdates
    }
}

