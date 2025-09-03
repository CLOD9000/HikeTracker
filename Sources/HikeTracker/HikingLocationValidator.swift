//
//  HikingLocationValidator.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import CoreLocation

internal class HikingLocationValidator {
    private let configuration: HikingLocationConfiguration
    
    init(configuration: HikingLocationConfiguration) {
        self.configuration = configuration
    }
    
    func isLocationValid(_ location: CLLocation,
                        lastValidLocation: CLLocation?,
                        lastUpdateTime: Date?) -> Bool {
        
        // Controlla accuratezza orizzontale
        guard location.horizontalAccuracy > 0 &&
              location.horizontalAccuracy <= configuration.maxHorizontalAccuracy else {
            return false
        }
        
        // Controlla accuratezza verticale (se disponibile)
        if location.verticalAccuracy > 0 {
            guard location.verticalAccuracy <= configuration.maxVerticalAccuracy else {
                return false
            }
        }
        
        // Controlla che la posizione non sia troppo vecchia
        let timeInterval = abs(location.timestamp.timeIntervalSinceNow)
        guard timeInterval < 10.0 else {
            return false
        }
        
        // Controlla intervallo minimo tra aggiornamenti
        if let lastUpdate = lastUpdateTime {
            let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
            guard timeSinceLastUpdate >= configuration.minTimeBetweenUpdates else {
                return false
            }
        }
        
        // Controlla velocità (filtra posizioni anomale)
        if let lastLocation = lastValidLocation {
            let distance = location.distance(from: lastLocation)
            let timeInterval = location.timestamp.timeIntervalSince(lastLocation.timestamp)
            
            if timeInterval > 0 {
                let speed = distance / timeInterval // m/s
                let maxReasonableSpeed = 20.0 // 72 km/h (massimo realistico per escursioni)
                
                guard speed <= maxReasonableSpeed else {
                    return false
                }
            }
        }
        
        return true
    }
}

