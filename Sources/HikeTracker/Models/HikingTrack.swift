//
//  HikingTrack.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import Foundation

public struct HikingTrack: Sendable {
    public let startTime: Date
    public var endTime: Date?
    public var locations: [HikingLocation]
    public var totalDistance: Double
    public var totalAscent: Double
    public var totalDescent: Double
    
    public init(startTime: Date) {
        self.startTime = startTime
        self.locations = []
        self.totalDistance = 0.0
        self.totalAscent = 0.0
        self.totalDescent = 0.0
    }
}

// Estensioni di utilità per HikingTrack
public extension HikingTrack {
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var averageSpeed: Double {
        guard duration > 0 else { return 0 }
        return totalDistance / duration // m/s
    }
    
    var maxAltitude: Double? {
        return locations.max { $0.altitude < $1.altitude }?.altitude
    }
    
    var minAltitude: Double? {
        return locations.min { $0.altitude < $1.altitude }?.altitude
    }
}
