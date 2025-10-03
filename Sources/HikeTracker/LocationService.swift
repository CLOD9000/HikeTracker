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
    
    private var lastLocation: CLLocation?
    /// Ultimo valore smussato dell’altitudine
    private var smoothedAltitudeValue: Double?
    
    /// Parametri di smoothing
    private let smoothingFactor = 0.2

    
    /// Soglie di validazione
    private let maxAccuracy: CLLocationAccuracy = 50   // metri
    private let maxAge: TimeInterval = 120              // secondi
    
    // MARK: - Init
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
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
        return smoothedAltitudeValue
    }
    
    public func getLastLocation() -> CLLocation? {
        return lastLocation
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

    // MARK: - Provate API
    
    /// Restituisce un'altitudine plausibile per simulatore
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// Restituisce altitudine smussata usando Exponential Moving Average
    private func smoothAltitude(_ rawAltitude: Double) -> Double {
        if let lastSmoothed = smoothedAltitudeValue {
            let newSmoothed = smoothingFactor * rawAltitude + (1 - smoothingFactor) * lastSmoothed
            smoothedAltitudeValue = newSmoothed
            return newSmoothed
        } else {
            smoothedAltitudeValue = rawAltitude
            return rawAltitude
        }
    }
    
    private func generateSimulatedAltitude() -> Double {
        // Genera un'altitudine plausibile tra 50 e 300 m
        // Per rendere più “realistica” puoi anche aggiungere una variazione graduale
        if let last = smoothedAltitudeValue {
            let variation = Double.random(in: -5...5) // piccola variazione
            let newAlt = max(50, min(300, last + variation))
            smoothedAltitudeValue = newAlt
            return newAlt
        } else {
            let initialAlt = Double.random(in: 50...300)
            smoothedAltitudeValue = initialAlt
            return initialAlt
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //guard let location = locations.last else { return }
        guard let rawLocation = locations.last else { return }

            let locationAge = -rawLocation.timestamp.timeIntervalSinceNow
            let horizontalAccuracy = rawLocation.horizontalAccuracy
        
        // --------- 1. Se è la prima posizione → accetta sempre ---------
            if lastLocation == nil {
                let smoothedAltitude = smoothAltitude(rawLocation.altitude)
                let simulatedAltitude = isSimulator ? generateSimulatedAltitude() : smoothedAltitude

                let firstLocation = CLLocation(
                    coordinate: rawLocation.coordinate,
                    altitude: simulatedAltitude,
                    horizontalAccuracy: horizontalAccuracy,
                    verticalAccuracy: rawLocation.verticalAccuracy,
                    timestamp: Date()
                )

                lastLocation = firstLocation
                onLocationUpdate?(firstLocation)
                print("✅ Prima posizione accettata (anche se vecchia)")
                return
            }
        
        // --------- 2. Scarta posizioni troppo vecchie ---------
            guard locationAge <= maxAge else {
                print("⚠️ Scartata posizione vecchia (\(locationAge)s)")
                return
            }
        
        // --------- 3. Scarta posizioni con accuracy troppo bassa ---------
        guard horizontalAccuracy >= 0, horizontalAccuracy <= 50 else {
            print("⚠️ Scartata posizione imprecisa (accuracy: \(horizontalAccuracy)m)")
            return
        }
        
        // --------- 4. Applica smoothing sull'altitudine ---------
        let smoothedAltitude = smoothAltitude(rawLocation.altitude)
        let simulatedAltitude = isSimulator ? generateSimulatedAltitude() : smoothedAltitude

        let cleanLocation = CLLocation(
            coordinate: rawLocation.coordinate,
            altitude: simulatedAltitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: rawLocation.verticalAccuracy,
            timestamp: Date()
        )

        lastLocation = cleanLocation
        onLocationUpdate?(cleanLocation)

    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        onAuthorizationChange?(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        onHeadingUpdate?(newHeading)
    }
}
