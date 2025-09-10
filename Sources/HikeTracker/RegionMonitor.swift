//
//  RegionMonitor
//  HikeTracker
//
//  Created by Claudio Ricco' on 10/09/25.
//

import CoreLocation
import UIKit

class RegionMonitor: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    private var onEnter: ((CLRegion) -> Void)?
    private var onExit: ((CLRegion) -> Void)?
    private var onError: ((Error) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    /// ✅ Avvia il monitoraggio di una regione circolare
    func startMonitoring(
        center: CLLocationCoordinate2D,
        radius: CLLocationDistance,
        identifier: String,
        onEnter: @escaping (CLRegion) -> Void,
        onExit: @escaping (CLRegion) -> Void,
        onError: ((Error) -> Void)? = nil
    ) {
        self.onEnter = onEnter
        self.onExit = onExit
        self.onError = onError
        
        let region = CLCircularRegion(center: center, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        // ⚠️ Apple limita il numero di regioni a 20 per app
        locationManager.startMonitoring(for: region)
    }
    
    /// ✅ Ferma il monitoraggio di una regione
    func stopMonitoring(identifier: String) {
        let regions = locationManager.monitoredRegions
        if let region = regions.first(where: { $0.identifier == identifier }) {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        onEnter?(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        onExit?(region)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        onError?(error)
    }
}
