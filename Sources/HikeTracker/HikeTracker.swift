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
    private let regionMonitor = RegionMonitor()

    public var isTracking = false
    public var isReturned = false

    private init() {}
    
    // MARK: - Permission
    public func checkAndRequestAuthorization(
        onStatusChange: @escaping (CLAuthorizationStatus) -> Void
    ) {
        permissionManager.checkAndRequestAuthorization(onStatusChange: onStatusChange)
    }
    
    public func currentAuthorizationStatus() -> CLAuthorizationStatus {
        return permissionManager.currentAuthorizationStatus()
    }

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

    public func checkPermissions() -> CLAuthorizationStatus {
        let status = permissionManager.checkAuthorizationStatus()
        return status
    }

    /// ✅ Nuovo metodo pubblico per osservare costantemente i permessi
    public func observePermissionChanges(onChange: @escaping (CLAuthorizationStatus) -> Void) {
        permissionManager.observeAuthorizationStatus(onChange: onChange)
    }

    @MainActor public func showSettingsAlert() {
        permissionManager.showSettingsAlert()
    }
    
    // MARK: - Location
    public func startTracking(
        onUpdate: @escaping (CLLocation) -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        guard !isTracking else { return } // ✅ evita doppio avvio
        isTracking = true
        locationService.startUpdatingLocation(onUpdate: onUpdate, onError: onError)
    }
    
    public func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        locationService.stopUpdatingLocation()
    }

//    public func startTracking(onUpdate: @escaping (HikeLocation) -> Void) {
//        locationService.startTracking(onUpdate: onUpdate)
//    }
//
//    public func stopTracking() {
//        locationService.stopTracking()
//    }
    
    // MARK: - Heading
    public func startUpdatingHeading(
        onUpdate: @escaping (CLHeading) -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        locationService.startUpdatingHeading(onUpdate: onUpdate, onError: onError)
    }
    
    public func stopUpdatingHeading() {
        locationService.stopUpdatingHeading()
    }
    
    // ✅ REGION MONITORING
        public func startRegionMonitoring(
            center: CLLocationCoordinate2D,
            radius: CLLocationDistance,
            identifier: String,
            onEnter: @escaping (CLRegion) -> Void,
            onExit: @escaping (CLRegion) -> Void,
            onError: ((Error) -> Void)? = nil
        ) {
            regionMonitor.startMonitoring(
                center: center,
                radius: radius,
                identifier: identifier,
                onEnter: onEnter,
                onExit: onExit,
                onError: onError
            )
        }
        
        public func stopRegionMonitoring(identifier: String) {
            regionMonitor.stopMonitoring(identifier: identifier)
        }
}
