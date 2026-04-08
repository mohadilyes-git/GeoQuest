//
//  LocationManager.swift
//  GeoQuest
//
//  Created by Ilyes Mo on 03/04/2026.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
    
    // Distance from user to a cache in metres
    func distanceTo(latitude: Double, longitude: Double) -> Double? {
        guard let userLocation = userLocation else { return nil }
        let cacheLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: cacheLocation)
    }
}
