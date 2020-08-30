//
//  LocationManager.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import CoreLocation

protocol LocationManager {
    var authorizationStatus: LocationAuthorizationStatus { get }
    var delegate: CLLocationManagerDelegate? { get set }
    func startUpdatingLocation()
    func requestAuthorization()
}

enum LocationAuthorizationStatus {
    case allowed, denied, unknown
}
