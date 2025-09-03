//
//  HikingTrackCalculator.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import CoreLocation

internal class HikingTrackCalculator {
    
    static func calculateTrackStatistics(for track: HikingTrack) -> (distance: Double, ascent: Double, descent: Double)? {
        guard track.locations.count > 1 else {
            return nil
        }
        
        var totalDistance: Double = 0
        var totalAscent: Double = 0
        var totalDescent: Double = 0
        
        for i in 1..<track.locations.count {
            let previousLocation = track.locations[i-1]
            let currentLocation = track.locations[i]
            
            // Calcola distanza
            let distance = calculateDistance(
                from: previousLocation.coordinate,
                to: currentLocation.coordinate
            )
            totalDistance += distance
            
            // Calcola dislivello
            let altitudeDiff = currentLocation.altitude - previousLocation.altitude
            if altitudeDiff > 0 {
                totalAscent += altitudeDiff
            } else {
                totalDescent += abs(altitudeDiff)
            }
        }
        
        return (distance: totalDistance, ascent: totalAscent, descent: totalDescent)
    }
    
    private static func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}

