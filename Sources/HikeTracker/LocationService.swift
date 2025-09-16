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
    private let maxAge: TimeInterval = 10              // secondi
    
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
        
        // --- Algoritmo di smoothing per l’altitudine ---
        let rawAltitude = location.altitude
        if let lastSmoothed = smoothedAltitude {
            smoothedAltitude = smoothingFactor * rawAltitude + (1 - smoothingFactor) * lastSmoothed
        } else {
            smoothedAltitude = rawAltitude
        }
        
        // ✅ Posizione valida → callback
        onLocationUpdate?(location)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        onAuthorizationChange?(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        onHeadingUpdate?(newHeading)
    }
}
