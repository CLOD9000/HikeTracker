import Foundation
import CoreLocation

public class HikeTracker: NSObject {
    @MainActor public static let shared = HikeTracker()
    
    private let locationManager = CLLocationManager()
    
    public var onLocationUpdate: ((CLLocation, Double) -> Void)?
    public var onError: ((Error) -> Void)?
    
    private var altitudeBuffer: [Double] = []
    private let maxBufferSize = 5
    
    private var currentMaxAccuracy: Double = 50
    private let targetAccuracy: Double = 20
    
    private var fixCount = 0
    private let fixesPerStep = 10
    private let stepReduction = 5.0
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    public func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    public func startTracking() {
        fixCount = 0
        currentMaxAccuracy = 50
        locationManager.startUpdatingLocation()
    }
    
    public func stopTracking() {
        locationManager.stopUpdatingLocation()
        altitudeBuffer.removeAll()
        fixCount = 0
    }
    
    private func smoothedAltitude(newAltitude: Double) -> Double {
        altitudeBuffer.append(newAltitude)
        if altitudeBuffer.count > maxBufferSize {
            altitudeBuffer.removeFirst()
        }
        return altitudeBuffer.reduce(0, +) / Double(altitudeBuffer.count)
    }
    
    private func reduceAccuracyIfNeeded() {
        guard currentMaxAccuracy > targetAccuracy else { return }
        fixCount += 1
        if fixCount >= fixesPerStep {
            fixCount = 0
            currentMaxAccuracy -= stepReduction
            if currentMaxAccuracy < targetAccuracy {
                currentMaxAccuracy = targetAccuracy
            }
        }
    }
}

extension HikeTracker: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            guard location.horizontalAccuracy > 0,
                  location.horizontalAccuracy < currentMaxAccuracy,
                  abs(location.timestamp.timeIntervalSinceNow) < 10
            else { continue }
            
            guard location.verticalAccuracy > 0,
                  location.verticalAccuracy < 15
            else { continue }
            
            if location.speed > 10 { continue }
            
            let smoothedAlt = smoothedAltitude(newAltitude: location.altitude)
            onLocationUpdate?(location, smoothedAlt)
            
            reduceAccuracyIfNeeded()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
}
