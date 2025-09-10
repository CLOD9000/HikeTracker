//
//  HikeLocation.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 09/09/25.
//

import CoreLocation

public struct HikeLocation {
    public let coordinate: CLLocationCoordinate2D
    public let altitude: CLLocationDistance
    public let horizontalAccuracy: CLLocationAccuracy
    public let verticalAccuracy: CLLocationAccuracy
    public let timestamp: Date
    public let location: CLLocation

}
