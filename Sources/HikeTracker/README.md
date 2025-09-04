//
//  Temp.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 04/09/25.
//

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


// MARK: - HikingTrack.swift


// MARK: - HikingLocationTypes.swift


// MARK: - HikingLocationConfiguration.swift


// MARK: - HikingLocationValidator.swift


// MARK: - HikingTrackCalculator.swift


// MARK: - HikingLocationTracker.swift


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
