//
//  HikeTracker.swift
//  HikeTracker
//
//  Created by Claudio Ricco' on 09/09/25.
//

import Foundation
import CoreLocation
import UIKit

/// Classe principale del framework, gestisce:
/// - Richiesta e monitoraggio permessi
/// - Tracking posizione + altitudine smussata
/// - Direzione bussola
/// - Region monitoring
@MainActor
public class HikeTracker {
    
    // ✅ Singleton
    public static let shared = HikeTracker()
    
    private let locationService = LocationService()
    private let permissionManager = PermissionManager()
    private let regionMonitor = RegionMonitor()
    
    public var isTracking = false
    
    private init() {}
    
    // MARK: - Permission
    
    /// Controlla lo stato dei permessi e, se necessario, li richiede
    public func checkAndRequestAuthorization(
        onStatusChange: @escaping (CLAuthorizationStatus) -> Void
    ) {
        permissionManager.checkAndRequestAuthorization(onStatusChange: onStatusChange)
    }
    
    /// Ritorna lo stato attuale dei permessi
    public func currentAuthorizationStatus() -> CLAuthorizationStatus {
        return permissionManager.currentAuthorizationStatus()
    }
    
    // MARK: - Tracking
    
    /// Avvia il tracking della posizione
    public func startTracking(
        onUpdate: @escaping (CLLocation, Double?) -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        guard !isTracking else { return }
        isTracking = true
        
        locationService.onLocationUpdate = { [weak self] location in
            guard let self = self else { return }
            let smoothedAlt = self.locationService.getSmoothedAltitude()
            onUpdate(location, smoothedAlt)
        }
        
        locationService.startUpdatingLocation()
    }
    
    /// Ferma il tracking
    public func stopTracking() {
        guard isTracking else { return }
        isTracking = false
        locationService.stopUpdatingLocation()
    }
    
    public func getDynamicFallbackLocation() -> CLLocation? {
        return locationService.getDynamicFallbackLocation()
    }
    
    // MARK: - Heading (direzione bussola)
    
    public func startHeadingUpdates(onUpdate: @escaping (CLHeading) -> Void) {
        locationService.onHeadingUpdate = onUpdate
        locationService.startUpdatingHeading()
    }
    
    public func stopHeadingUpdates() {
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



