//
//  HikeTracker.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 09/09/25.
//

import Foundation
import CoreLocation
import UIKit

public class HikeTracker {
    @MainActor public static let shared = HikeTracker()
    
    private let locationService = LocationService()
    private let permissionManager = PermissionManager()

    private init() {}

    public func requestWhenInUseAuthorization(completion: @escaping (Bool) -> Void) {
        permissionManager.requestWhenInUseAuthorization { status in
            completion(status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }

    public func requestAlwaysAuthorization(completion: @escaping (Bool) -> Void) {
        permissionManager.requestAlwaysAuthorization { status in
            completion(status == .authorizedAlways)
        }
    }

    public func checkPermissions() -> Bool {
        let status = permissionManager.checkAuthorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }

    /// ✅ Nuovo metodo pubblico per osservare costantemente i permessi
    public func observePermissionChanges(onChange: @escaping (CLAuthorizationStatus) -> Void) {
        permissionManager.observeAuthorizationStatus(onChange: onChange)
    }

    @MainActor public func showSettingsAlert() {
        permissionManager.showSettingsAlert()
    }

    public func startTracking(onUpdate: @escaping (HikeLocation) -> Void) {
        locationService.startTracking(onUpdate: onUpdate)
    }

    public func stopTracking() {
        locationService.stopTracking()
    }
}
