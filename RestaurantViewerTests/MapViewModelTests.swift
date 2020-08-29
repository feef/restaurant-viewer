//
//  MapViewModelTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
import RxSwift
import CoreLocation
@testable import RestaurantViewer

class MapViewModelTests: XCTestCase {
    var apiManager: LocalAPIManager!
    var disposeBag: DisposeBag!
    var locationManager: DummyLocationManager!
    var mapViewModel: MapViewModel!
    
    override func setUp() {
        apiManager = LocalAPIManager()
        disposeBag = DisposeBag()
        locationManager = DummyLocationManager()
        mapViewModel = MapViewModel(apiManager: apiManager, locationManager: locationManager)
    }
    
    override func tearDown() {
        apiManager = nil
        disposeBag = nil
        locationManager = nil
        mapViewModel = nil
    }
    
    // MARK: - handleViewDidLoad
    
    func testLocationAuthorizationRequested() {
        locationManager.authorizationStatus = .unknown
        let expectation = XCTestExpectation(description: "Location authorization is requested in view did load handling when location manager state is unknown")
        locationManager.onAuthorizationRequested = {
            expectation.fulfill()
        }
        mapViewModel.handleViewDidLoad()
        wait(for: [expectation], timeout: 1)
    }
    
    func testLocationAlertShown() {
        locationManager.authorizationStatus = .denied
        let expectation = XCTestExpectation(description: "An alert is relayed in view did load handling when location manager state is denied")
        mapViewModel.alertRelay.subscribe(onNext: { _ in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        mapViewModel.handleViewDidLoad()
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartTrackingLocation() {
        locationManager.authorizationStatus = .allowed
        let updatingLocationExpectation = XCTestExpectation(description: "The view model begins tracking user location in view did load handling when location manager state is allowed")
        locationManager.onStartUpdatingLocation = {
            updatingLocationExpectation.fulfill()
        }
        mapViewModel.handleViewDidLoad()
        wait(for: [updatingLocationExpectation], timeout: 1)
    }
    
    // MARK: - handleUserLocations
    
    func testNoUserLocations() {
        apiManager.onFetchRestaurants = { _, _ in
            XCTFail("Unexpected call to 'fetchRestaurants' from 'handleUserLocations'")
        }
        mapViewModel.handleUserLocations([])
    }
    
    func testFetchBasedOnUserLocations() {
        let userLocation = CLLocation(latitude: 10, longitude: 11)
        let fetchRestaurantsExpectation = XCTestExpectation(description: "The view model fetches restaurants based on the user's current location with default radius of 100 when 'handleUserLocations' is called")
        apiManager.onFetchRestaurants = { coordinate, radius in
            XCTAssertEqual(coordinate.latitude, userLocation.coordinate.latitude)
            XCTAssertEqual(coordinate.longitude, userLocation.coordinate.longitude)
            XCTAssertEqual(radius, 250)
            fetchRestaurantsExpectation.fulfill()
        }
        let regionUpdatedExpectation = XCTestExpectation(description: "The view model updates the map region after fetching restaurant locations in view did load handling when location manager state is allowed")
        mapViewModel.regionRelay.subscribe(onNext: { _ in
                regionUpdatedExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        mapViewModel.handleUserLocations([CLLocation(latitude: 200, longitude: 210), userLocation])
        wait(for: [fetchRestaurantsExpectation, regionUpdatedExpectation], timeout: 1)
    }
}
