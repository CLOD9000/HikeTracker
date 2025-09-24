//
//  LocationService.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 09/09/25.
//

import CoreLocation

/// Servizio per tracciare la posizione, direzione e altitudine dell’utente.
/// Include:
/// - Callback tramite closure
/// - Smoothing per l’altitudine
/// - Filtro per scartare posizioni vecchie o inaccurate
public class LocationService: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    /// Callback invocata quando viene ricevuta una nuova posizione valida
    public var onLocationUpdate: ((CLLocation) -> Void)?
    
    /// Callback invocata quando cambia lo stato dei permessi
    public var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    
    /// Callback per la direzione bussola
    public var onHeadingUpdate: ((CLHeading) -> Void)?
    
    /// Ultimo valore smussato dell’altitudine
    private var smoothedAltitude: Double?
    
    /// Parametri di smoothing
    private let smoothingFactor = 0.2
    
    /// Soglie di validazione
    private let maxAccuracy: CLLocationAccuracy = 50   // metri
    private let maxAge: TimeInterval = 60              // secondi
    
    // MARK: - Init
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
    }
    
    // MARK: - Public API
    
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func startUpdatingHeading() {
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
    }
    
    public func stopUpdatingHeading() {
        locationManager.stopUpdatingHeading()
    }
    
    public func getSmoothedAltitude() -> Double? {
        return smoothedAltitude
    }
        
    /// Restituisce una posizione realistica, anche se non precisa,
    /// provando a rilassare progressivamente l'accuratezza richiesta.
    /// - Parameter thresholds: soglie di accuratezza da provare (in metri).
    /// - Returns: CLLocation valida oppure nil.
    public func getDynamicFallbackLocation(
        thresholds: [CLLocationAccuracy] = [100, 250, 500, 1000]
    ) -> CLLocation? {
        
        guard let lastLocation = locationManager.location else {
            return nil
        }
        
        // Controlla se la posizione soddisfa una delle soglie
        for threshold in thresholds {
            if lastLocation.horizontalAccuracy <= threshold {
                return lastLocation
            }
        }
        
        // Se non soddisfa nessuna soglia, ma è comunque "plausibile", la aggiustiamo
        if lastLocation.horizontalAccuracy <= 10_000 {
            let adjustedLocation = CLLocation(
                coordinate: lastLocation.coordinate,
                altitude: lastLocation.altitude,
                horizontalAccuracy: thresholds.last ?? 1000,
                verticalAccuracy: lastLocation.verticalAccuracy,
                course: lastLocation.course,
                speed: lastLocation.speed,
                timestamp: lastLocation.timestamp
            )
            return adjustedLocation
        }
        
        // Se è totalmente sbagliata (accuratezza > 10 km), scartiamo
        return nil
    }


    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 🛑 Filtro per scartare posizioni non affidabili
        let locationAge = -location.timestamp.timeIntervalSinceNow
        guard locationAge <= maxAge else {
            print("⚠️ Scartata posizione vecchia (\(locationAge)s)")
            return
        }
        
        guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= maxAccuracy else {
            print("⚠️ Scartata posizione imprecisa (\(location.horizontalAccuracy)m)")
            return
        }
        
        // --- Smoothing altitudine ---
        var altitudeToUse = location.altitude
        if let lastSmoothed = smoothedAltitude {
            smoothedAltitude = smoothingFactor * altitudeToUse + (1 - smoothingFactor) * lastSmoothed
        } else {
            smoothedAltitude = altitudeToUse
        }
        altitudeToUse = smoothedAltitude ?? altitudeToUse
        
        // --- Se simulatore: genera altitudine realistica ---
        #if targetEnvironment(simulator)
        altitudeToUse = Double.random(in: 50...300)
        #endif
        
        // ✅ Creiamo un nuovo CLLocation con altitudine aggiornata
        let adjustedLocation = CLLocation(
            coordinate: location.coordinate,
            altitude: altitudeToUse,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            course: location.course,
            speed: location.speed,
            timestamp: location.timestamp
        )
        
        // 🔔 Callback con la nuova CLLocation “pulita”
        onLocationUpdate?(adjustedLocation)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        onAuthorizationChange?(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        onHeadingUpdate?(newHeading)
    }
}
