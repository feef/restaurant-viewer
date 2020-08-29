//
//  UserLocationManagerTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
@testable import RestaurantViewer

class UserLocationManagerTests: XCTestCase {
    func testAuthorizationMapping() {
        let userLocationManager = UserLocationManager(locationManager: DummyCLLocationManager())
        DummyCLLocationManager._authorizationStatus = .authorizedAlways
        XCTAssertEqual(userLocationManager.authorizationStatus, .allowed)
        DummyCLLocationManager._authorizationStatus = .authorizedWhenInUse
        XCTAssertEqual(userLocationManager.authorizationStatus, .allowed)
        DummyCLLocationManager._authorizationStatus = .denied
        XCTAssertEqual(userLocationManager.authorizationStatus, .denied)
        DummyCLLocationManager._authorizationStatus = .notDetermined
        XCTAssertEqual(userLocationManager.authorizationStatus, .unknown)
        DummyCLLocationManager._authorizationStatus = .restricted
        XCTAssertEqual(userLocationManager.authorizationStatus, .denied)
    }
    
    func testMethodForwarding() {
        let dummyCLLocationManager = DummyCLLocationManager()
        let userLocationManager = UserLocationManager(locationManager: dummyCLLocationManager)
        let authorizationExpectation = XCTestExpectation(description: "UserLocationManager will call 'requestAuthorization' on CLLocationManager when 'requestAuthorization' is called on it")
        dummyCLLocationManager.onRequestAuthorization = {
            authorizationExpectation.fulfill()
        }
        userLocationManager.requestAuthorization()
        wait(for: [authorizationExpectation], timeout: 1)
        
        let trackingExpectation = XCTestExpectation(description: "UserLocationManager will call 'startUpdatingLocation' on CLLocationManager when 'startUpdatingLocation' is called on it")
        dummyCLLocationManager.onStartUpdatingLocation = {
            trackingExpectation.fulfill()
        }
        userLocationManager.startUpdatingLocation()
        wait(for: [trackingExpectation], timeout: 1)
    }
}
