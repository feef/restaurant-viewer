//
//  DummyLocationManager.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import CoreLocation
@testable import RestaurantViewer

class DummyLocationManager: LocationManager {
    var authorizationStatus: LocationAuthorizationStatus = .unknown
    var delegate: CLLocationManagerDelegate?
    
    var onAuthorizationRequested: (() -> Void)?
    var onStartUpdatingLocation: (() -> Void)?
    
    // calls the 'onStartUpdatingLocation' block
    func startUpdatingLocation() {
        onStartUpdatingLocation?()
    }
    
    // calls the 'onAuthorizationRequested' block
    func requestAuthorization() {
        onAuthorizationRequested?()
    }
}
