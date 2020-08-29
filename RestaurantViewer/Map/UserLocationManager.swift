//
//  UserLocationManager.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import CoreLocation

class UserLocationManager: LocationManager {
    private let locationManager: CLLocationManager
    
    var authorizationStatus: LocationAuthorizationStatus {
        switch type(of: locationManager).authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                return .allowed
            case .notDetermined:
                return .unknown
            case .denied, .restricted:
                return .denied
            @unknown default:
                return .unknown
        }
    }
    
    var delegate: CLLocationManagerDelegate? {
        set {
            locationManager.delegate = newValue
        }
        get {
            return locationManager.delegate
        }
    }
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}
