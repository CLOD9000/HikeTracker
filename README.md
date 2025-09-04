// MARK: - Esempio di utilizzo avanzato
/*
// ExampleViewController.swift - Gestione completa delle autorizzazioni
class ExampleViewController: UIViewController {
    
    private let tracker = HikingLocationTracker(configuration: .hiking)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationTracking()
    }
    
    // MARK: - Esempio 1: Richiesta step-by-step (CONSIGLIATO)
    private func setupLocationTracking() {
        // Mostra il rationale se necessario
        let rationale = tracker.shouldShowPermissionRationale()
        if rationale.whenInUse {
            showWhenInUseRationale()
        } else if rationale.always {
            showAlwaysRationale()
        }
        
        // Richiedi permessi step-by-step con feedback utente
        tracker.requestPermissionsStepByStep { [weak self] status, message in
            DispatchQueue.main.async {
                self?.showPermissionStep(status: status, message: message)
            }
        }
    }
    
    // MARK: - Esempio 2: Richiesta automatica
    private func requestAutomaticPermission() {
        tracker.requestRequiredPermission { [weak self] status in
            DispatchQueue.main.async {
                self?.handleAuthorization(status)
            }
        }
    }
    
    // MARK: - Esempio 3: Richiesta manuale separata
    private func requestManualPermissions() {
        // Prima richiedi whenInUse
        tracker.requestWhenInUsePermission { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorizedWhenInUse:
                    self?.showWhenInUseSuccess()
                    // Poi chiedi se vuole il permesso always
                    self?.askForAlwaysPermission()
                case .denied:
                    self?.showPermissionDenied()
                default:
                    break
                }
            }
        }
    }
    
    private func askForAlwaysPermission() {
        let alert = UIAlertController(
            title: "Tracking in Background",
            message: "Per tracciare la tua escursione anche quando l'app è in background, concedi il permesso 'Sempre'",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Concedi", style: .default) { [weak self] _ in
            self?.tracker.requestAlwaysPermission { status in
                DispatchQueue.main.async {
                    self?.handleAlwaysPermission(status)
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Non ora", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Handler per le autorizzazioni
    private func handleAuthorization(_ status: LocationAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            startHiking()
        case .authorizedWhenInUse:
            if tracker.configuration.backgroundLocationUpdates {
                showLimitedFunctionality()
            } else {
                startHiking()
            }
        case .denied:
            showPermissionDenied()
        default:
            break
        }
    }
    
    private func handleAlwaysPermission(_ status: LocationAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            showAlwaysPermissionGranted()
            startHiking()
        case .authorizedWhenInUse:
            showAlwaysPermissionPartiallyGranted()
            startHiking()
        case .denied:
            showAlwaysPermissionDenied()
        default:
            break
        }
    }
    
    // MARK: - UI Feedback Methods
    private func showPermissionStep(status: LocationAuthorizationStatus, message: String) {
        print("Step: \(message)")
        
        switch status {
        case .authorizedAlways:
            showSuccessMessage("Perfetto! Tracking completo abilitato")
            startHiking()
        case .authorizedWhenInUse:
            // Il manager continuerà automaticamente con always
            showInfoMessage(message)
        case .denied:
            showPermissionDeniedAlert()
        default:
            showInfoMessage(message)
        }
    }
    
    private func showWhenInUseRationale() {
        let alert = UIAlertController(
            title: "Accesso alla Posizione",
            message: "Questa app ha bisogno di accedere alla tua posizione per tracciare il percorso dell'escursione.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlwaysRationale() {
        let alert = UIAlertController(
            title: "Tracking in Background",
            message: "Per tracciare la tua escursione anche quando il telefono è bloccato o l'app è in background, è necessario il permesso 'Sempre'.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Capito", style: .default))
        present(alert, animated: true)
    }
    
    private func showWhenInUseSuccess() {
        showSuccessMessage("Permesso base concesso!")
    }
    
    private func showAlwaysPermissionGranted() {
        showSuccessMessage("Ottimo! Tracking completo abilitato")
    }
    
    private func showAlwaysPermissionPartiallyGranted() {
        showInfoMessage("Tracking limitato al primo piano dell'app")
    }
    
    private func showAlwaysPermissionDenied() {
        let alert = UIAlertController(
            title: "Permesso Limitato",
            message: "Il tracking funzionerà solo quando l'app è attiva. Puoi cambiare questo nelle Impostazioni.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Impostazioni", style: .default) { _ in
            self.openSettings()
        })
        alert.addAction(UIAlertAction(title: "Continua", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showPermissionDenied() {
        let alert = UIAlertController(
            title: "Accesso Negato",
            message: "L'accesso alla posizione è necessario per il funzionamento dell'app.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Impostazioni", style: .default) { _ in
            self.openSettings()
        })
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showPermissionDeniedAlert() {
        showPermissionDenied()
    }
    
    private func showLimitedFunctionality() {
        let alert = UIAlertController(
            title: "Funzionalità Limitata",
            message: "Il tracking si fermerà quando l'app va in background. Vuoi abilitare il tracking completo?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Abilita", style: .default) { [weak self] _ in
            self?.askForAlwaysPermission()
        })
        alert.addAction(UIAlertAction(title: "Continua così", style: .cancel) { [weak self] _ in
            self?.startHiking()
        })
        present(alert, animated: true)
    }
    
    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(title: "✅ Successo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showInfoMessage(_ message: String) {
        print("ℹ️ Info: \(message)")
        // Oppure mostra in una label/banner nell'UI
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    // MARK: - Tracking Methods
    private func startHiking() {
        tracker.startTracking(
            onLocationUpdate: { [weak self] location in
                DispatchQueue.main.async {
                    self?.updateUI(with: location)
                }
            },
            onError: { error in
                DispatchQueue.main.async {
                    self.handleTrackingError(error)
                }
            }
        )
    }
    
    private func stopHiking() {
        tracker.stopTracking { [weak self] track in
            DispatchQueue.main.async {
                self?.saveAndShowTrack(track)
            }
        }
    }
    
    private func updateUI(with location: HikingLocation) {
        // Aggiorna l'interfaccia utente con la nuova posizione
        print("📍 Nuova posizione: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("⛰️ Altitudine: \(location.altitude)m")
        
        // Aggiorna statistiche in tempo reale
        if let stats = tracker.calculateTrackStatistics() {
            updateStatsUI(distance: stats.distance, ascent: stats.ascent, descent: stats.descent)
        }
    }
    
    private func updateStatsUI(distance: Double, ascent: Double, descent: Double) {
        print("📊 Distanza: \(String(format: "%.1f", distance))m")
        print("📈 Salita: \(String(format: "%.1f", ascent))m")
        print("📉 Discesa: \(String(format: "%.1f", descent))m")
    }
    
    private func handleTrackingError(_ error: HikingLocationError) {
        let alert = UIAlertController(
            title: "Errore Tracking",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func saveAndShowTrack(_ track: HikingTrack) {
        print("🏁 Escursione completata!")
        print("⏱️ Durata: \(String(format: "%.1f", track.duration/60)) minuti")
        print("📍 Punti registrati: \(track.locations.count)")
        print("📊 Distanza totale: \(String(format: "%.1f", track.totalDistance))m")
        
        // Salva il track (Core Data, file, cloud, etc.)
        // saveTrackToPersistence(track)
        
        // Mostra schermata riepilogo
        showTrackSummary(track)
    }
    
    private func showTrackSummary(_ track: HikingTrack) {
        let alert = UIAlertController(
            title: "🎉 Escursione Completata!",
            message: """
            Durata: \(String(format: "%.1f", track.duration/60)) min
            Distanza: \(String(format: "%.2f", track.totalDistance/1000)) km
            Dislivello +: \(String(format: "%.0f", track.totalAscent))m
            Dislivello -: \(String(format: "%.0f", track.totalDescent))m
            Punti GPS: \(track.locations.count)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Fantastico!", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Esempio utilizzo stato permessi
    private func checkPermissionStatus() {
        let status = tracker.authorizationStatus
        let canRequestAlways = tracker.canRequestAlwaysAuthorization()
        
        print("Stato attuale: \(status)")
        print("Può richiedere 'Always': \(canRequestAlways)")
        
        // Logica basata sullo stato
        switch status {
        case .notDetermined:
            // Prima volta, richiedi permessi
            requestAutomaticPermission()
        case .authorizedWhenInUse:
            if canRequestAlways && tracker.configuration.backgroundLocationUpdates {
                askForAlwaysPermission()
            }
        case .authorizedAlways:
            // Tutto OK, puoi iniziare il tracking
            break
        case .denied, .restricted:
            // Mostra come abilitare nelle impostazioni
            showPermissionDenied()
        }
    }
}

// MARK: - Estensione per gestire i lifecycle events
extension ExampleViewController {
    
    override func viewWillEnterForeground(_ animated: Bool) {
        super.viewWillEnterForeground(animated)
        
        // Ricontrolla lo stato dei permessi quando l'app torna attiva
        // L'utente potrebbe aver cambiato i permessi nelle Impostazioni
        checkPermissionStatus()
    }
    
    override func viewDidEnterBackground() {
        // Se hai solo whenInUse, potresti voler pausare e mostrare un avviso
        if tracker.authorizationStatus == .authorizedWhenInUse &&
           tracker.configuration.backgroundLocationUpdates {
            showBackgroundLimitationWarning()
        }
    }
    
    private func showBackgroundLimitationWarning() {
        // Mostra notifica locale o banner che il tracking si fermerà
        print("⚠️ Tracking si fermerà in background con permesso 'When In Use'")
    }
}
*/// MARK: - HikingLocation.swift
import Foundation
import CoreLocation

public struct HikingLocation: Sendable {
    public let coordinate: CLLocationCoordinate2D
    public let altitude: Double
    public let horizontalAccuracy: Double
    public let verticalAccuracy: Double
    public let timestamp: Date
    public let speed: Double
    public let course: Double
    
    public init(from location: CLLocation) {
        self.coordinate = location.coordinate
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.timestamp = location.timestamp
        self.speed = location.speed
        self.course = location.course
    }
}

// MARK: - HikingTrack.swift
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

// MARK: - HikingLocationTypes.swift
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

// MARK: - HikingLocationConfiguration.swift
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

// MARK: - HikingLocationValidator.swift
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

// MARK: - HikingTrackCalculator.swift
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

// MARK: - HikingLocationTracker.swift
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
