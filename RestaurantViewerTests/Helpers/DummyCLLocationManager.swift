//
//  DummyCLLocationManager.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import CoreLocation

class DummyCLLocationManager: CLLocationManager {
    static var _authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override class func authorizationStatus() -> CLAuthorizationStatus {
        return _authorizationStatus
    }
    
    var onRequestAuthorization: (() -> Void)?
    var onStartMonitoringSignificantLocationChanges: (() -> Void)?
    
    override init() {
        super.init()
    }
    
    override func requestWhenInUseAuthorization() {
        onRequestAuthorization?()
    }
    
    override func startMonitoringSignificantLocationChanges() {
        onStartMonitoringSignificantLocationChanges?()
    }
}
