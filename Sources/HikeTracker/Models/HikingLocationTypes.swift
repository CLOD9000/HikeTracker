//
//  HikingLocationTypes.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import Foundation

public enum LocationAuthorizationStatus: Sendable {
    case notDetermined
    case denied
    case authorizedWhenInUse
    case authorizedAlways
    case restricted
}

public enum HikingLocationError: Error, LocalizedError, Sendable {
    case locationServicesDisabled
    case authorizationDenied
    case inaccurateLocation
    case backgroundLocationNotAllowed
    case trackingNotStarted
    
    public var errorDescription: String? {
        switch self {
        case .locationServicesDisabled:
            return "Servizi di localizzazione disabilitati"
        case .authorizationDenied:
            return "Autorizzazione localizzazione negata"
        case .inaccurateLocation:
            return "Posizione troppo imprecisa"
        case .backgroundLocationNotAllowed:
            return "Localizzazione in background non autorizzata"
        case .trackingNotStarted:
            return "Tracking non avviato"
        }
    }
}

