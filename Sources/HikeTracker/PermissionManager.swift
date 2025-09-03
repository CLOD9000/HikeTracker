//
//  PermissionManager.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 03/09/25.
//
import CoreLocation
import UIKit

class PermissionManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var completion: ((CLAuthorizationStatus) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestWhenInUseAuthorization(completion: @escaping (CLAuthorizationStatus) -> Void) {
        self.completion = completion
        locationManager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization(completion: @escaping (CLAuthorizationStatus) -> Void) {
        self.completion = completion
        locationManager.requestAlwaysAuthorization()
    }

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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        completion?(status)
        completion = nil
    }
}

