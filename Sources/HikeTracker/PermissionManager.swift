//
//  PermissionManager.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 09/09/25.
//

import CoreLocation
import UIKit

class PermissionManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    /// ✅ Callback che rimane attiva per monitorare lo stato
    private var onStatusChanged: ((CLAuthorizationStatus) -> Void)?
    
    /// Callback singola (una tantum)
    private var singleCompletion: ((CLAuthorizationStatus) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // Richiesta "When In Use"
    func requestWhenInUseAuthorization(completion: @escaping (CLAuthorizationStatus) -> Void) {
        self.singleCompletion = completion
        locationManager.requestWhenInUseAuthorization()
    }

    // Richiesta "Always"
    func requestAlwaysAuthorization(completion: @escaping (CLAuthorizationStatus) -> Void) {
        self.singleCompletion = completion
        locationManager.requestAlwaysAuthorization()
    }

    // ✅ Monitoraggio continuo
    func observeAuthorizationStatus(onChange: @escaping (CLAuthorizationStatus) -> Void) {
        self.onStatusChanged = onChange
        // Inviamo subito lo stato corrente
        if #available(iOS 14.0, *) {
            onChange(locationManager.authorizationStatus)
        } else {
            onChange(CLLocationManager.authorizationStatus())
        }
    }

    // ✅ Controllo singolo
    func checkAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    @MainActor func showSettingsAlert() {
        guard let topVC = UIApplication.shared.windows.first?.rootViewController else { return }
        let alert = UIAlertController(
            title: "Permesso di localizzazione richiesto",
            message: "Per monitorare il tuo percorso, abilita la posizione nelle Impostazioni.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        alert.addAction(UIAlertAction(title: "Impostazioni", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        topVC.present(alert, animated: true)
    }

    // Delegate CoreLocation
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Notifica per la richiesta una tantum
        singleCompletion?(status)
        singleCompletion = nil
        
        // Notifica continua
        onStatusChanged?(status)
    }
}
