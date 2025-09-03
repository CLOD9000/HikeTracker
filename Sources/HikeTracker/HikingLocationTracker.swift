//
//  HikingLocationTracker.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//

import Foundation
import CoreLocation
import UIKit

public class HikingLocationTracker: NSObject {
    
    // MARK: - Typealias per le closures
    public typealias LocationUpdateHandler = @Sendable (HikingLocation) -> Void
    public typealias ErrorHandler = @Sendable (HikingLocationError) -> Void
    public typealias AuthorizationHandler = @Sendable (LocationAuthorizationStatus) -> Void
    public typealias TrackCompletionHandler = @Sendable (HikingTrack) -> Void
    
    // MARK: - Proprietà private
    private let locationManager = CLLocationManager()
    private let configuration: HikingLocationConfiguration
    private let validator: HikingLocationValidator
    private var currentTrack: HikingTrack?
    private var lastValidLocation: CLLocation?
    private var lastUpdateTime: Date?
    private var isTracking = false
    
    // MARK: - Closures
    private var locationUpdateHandler: LocationUpdateHandler?
    private var errorHandler: ErrorHandler?
    private var authorizationHandler: AuthorizationHandler?
    private var trackCompletionHandler: TrackCompletionHandler?
    
    // MARK: - Inizializzazione
    public init(configuration: HikingLocationConfiguration = .hiking) {
        self.configuration = configuration
        self.validator = HikingLocationValidator(configuration: configuration)
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = configuration.desiredAccuracy
        locationManager.distanceFilter = configuration.distanceFilter
        
        if configuration.backgroundLocationUpdates {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
        }
    }
    
    // MARK: - Metodi pubblici per gestione autorizzazioni
    public func requestLocationPermission(completion: @escaping AuthorizationHandler) {
        authorizationHandler = completion
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            if configuration.backgroundLocationUpdates {
                locationManager.requestAlwaysAuthorization()
            } else {
                locationManager.requestWhenInUseAuthorization()
            }
        case .denied, .restricted:
            completion(.denied)
        case .authorizedWhenInUse:
            if configuration.backgroundLocationUpdates {
                locationManager.requestAlwaysAuthorization()
            } else {
                completion(.authorizedWhenInUse)
            }
        case .authorizedAlways:
            completion(.authorizedAlways)
        @unknown default:
            completion(.denied)
        }
    }
    
    public var authorizationStatus: LocationAuthorizationStatus {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorizedWhenInUse:
            return .authorizedWhenInUse
        case .authorizedAlways:
            return .authorizedAlways
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    // MARK: - Metodi di tracking
    public func startTracking(
        onLocationUpdate: @escaping LocationUpdateHandler,
        onError: @escaping ErrorHandler
    ) {
        guard CLLocationManager.locationServicesEnabled() else {
            onError(.locationServicesDisabled)
            return
        }
        
        guard authorizationStatus == .authorizedAlways ||
              (!configuration.backgroundLocationUpdates && authorizationStatus == .authorizedWhenInUse) else {
            onError(.authorizationDenied)
            return
        }
        
        locationUpdateHandler = onLocationUpdate
        errorHandler = onError
        
        currentTrack = HikingTrack(startTime: Date())
        isTracking = true
        
        locationManager.startUpdatingLocation()
        
        // Per massima precisione, richiediamo anche aggiornamenti significativi
        if configuration.backgroundLocationUpdates {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    public func stopTracking(completion: @escaping TrackCompletionHandler) {
        guard var track = currentTrack else {
            return
        }
        
        isTracking = false
        track.endTime = Date()
        
        locationManager.stopUpdatingLocation()
        if configuration.backgroundLocationUpdates {
            locationManager.stopMonitoringSignificantLocationChanges()
        }
        
        completion(track)
        currentTrack = nil
        locationUpdateHandler = nil
        errorHandler = nil
    }
    
    public func pauseTracking() {
        guard isTracking else { return }
        locationManager.stopUpdatingLocation()
    }
    
    public func resumeTracking() {
        guard isTracking else { return }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Metodi di utilità
    public var currentTrackInfo: HikingTrack? {
        return currentTrack
    }
    
    public func calculateTrackStatistics() -> (distance: Double, ascent: Double, descent: Double)? {
        guard let track = currentTrack else { return nil }
        return HikingTrackCalculator.calculateTrackStatistics(for: track)
    }
    
    // MARK: - Metodi privati
    private func processValidLocation(_ location: CLLocation) {
        let hikingLocation = HikingLocation(from: location)
        
        // Aggiorna il track corrente
        if var track = currentTrack {
            track.locations.append(hikingLocation)
            
            // Calcola statistiche aggiornate se abbiamo almeno 2 punti
            if track.locations.count > 1 {
                if let stats = HikingTrackCalculator.calculateTrackStatistics(for: track) {
                    track.totalDistance = stats.distance
                    track.totalAscent = stats.ascent
                    track.totalDescent = stats.descent
                }
            }
            
            currentTrack = track
        }
        
        // Aggiorna riferimenti
        lastValidLocation = location
        lastUpdateTime = Date()
        
        // Chiama la closure
        locationUpdateHandler?(hikingLocation)
    }
}

// MARK: - CLLocationManagerDelegate
extension HikingLocationTracker: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        
        // Processa tutte le posizioni ricevute
        for location in locations {
            if validator.isLocationValid(location,
                                       lastValidLocation: lastValidLocation,
                                       lastUpdateTime: lastUpdateTime) {
                processValidLocation(location)
            } else {
                errorHandler?(.inaccurateLocation)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                errorHandler?(.authorizationDenied)
            case .locationUnknown, .network:
                // Non interrompere il tracking per errori temporanei
                break
            default:
                break
            }
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: LocationAuthorizationStatus
        
        switch manager.authorizationStatus {
        case .notDetermined:
            status = .notDetermined
        case .denied:
            status = .denied
            if isTracking {
                errorHandler?(.authorizationDenied)
            }
        case .authorizedWhenInUse:
            status = .authorizedWhenInUse
            if configuration.backgroundLocationUpdates {
                errorHandler?(.backgroundLocationNotAllowed)
            }
        case .authorizedAlways:
            status = .authorizedAlways
        case .restricted:
            status = .restricted
            if isTracking {
                errorHandler?(.authorizationDenied)
            }
        @unknown default:
            status = .denied
        }
        
        authorizationHandler?(status)
    }
}

// MARK: - Esempio di utilizzo
/*
// ExampleViewController.swift
class ExampleViewController: UIViewController {
    
    private let tracker = HikingLocationTracker(configuration: .hiking)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationTracking()
    }
    
    private func setupLocationTracking() {
        tracker.requestLocationPermission { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Permesso concesso")
                case .denied:
                    print("Permesso negato")
                default:
                    break
                }
            }
        }
    }
    
    private func startHiking() {
        tracker.startTracking(
            onLocationUpdate: { [weak self] location in
                DispatchQueue.main.async {
                    self?.updateUI(with: location)
                }
            },
            onError: { error in
                DispatchQueue.main.async {
                    print("Errore: \(error.localizedDescription)")
                }
            }
        )
    }
    
    private func stopHiking() {
        tracker.stopTracking { [weak self] track in
            DispatchQueue.main.async {
                self?.saveTrack(track)
            }
        }
    }
    
    private func updateUI(with location: HikingLocation) {
        // Aggiorna l'interfaccia utente
    }
    
    private func saveTrack(_ track: HikingTrack) {
        // Salva il percorso
    }
}
*/
