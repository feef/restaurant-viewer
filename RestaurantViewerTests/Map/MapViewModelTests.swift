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
import MapKit
@testable import RestaurantViewer

class MapViewModelTests: XCTestCase {
    var apiManager: LocalAPIManager!
    var disposeBag: DisposeBag!
    var locationManager: DummyLocationManager!
    var mapViewModel: MapViewModel!
    var onCompleteIfUnused: (() -> Void)?
    var onShowDetailsForRestaurant: ((String) -> Void)?
    
    override func setUp() {
        apiManager = LocalAPIManager()
        disposeBag = DisposeBag()
        locationManager = DummyLocationManager()
        mapViewModel = MapViewModel(delegate: nil, apiManager: apiManager, locationManager: locationManager)
    }
    
    override func tearDown() {
        apiManager = nil
        disposeBag = nil
        locationManager = nil
        mapViewModel = nil
        onCompleteIfUnused = nil
        onShowDetailsForRestaurant = nil
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
    
    func testFetchBasedOnUserLocationsSuccess() {
        let userLocation = CLLocation(latitude: 0.5, longitude: 11.1)
        let fetchRestaurantsExpectation = XCTestExpectation(description: "The view model fetches restaurants based on the user's current location with default radius of 100 when 'handleUserLocations' is called")
        apiManager.onFetchRestaurants = { coordinate, radius in
            XCTAssertEqual(coordinate.latitude, userLocation.coordinate.latitude)
            XCTAssertEqual(coordinate.longitude, userLocation.coordinate.longitude)
            XCTAssertEqual(radius, 250)
            fetchRestaurantsExpectation.fulfill()
        }
        let regionUpdatedExpectation = XCTestExpectation(description: "The view model updates the map region after fetching restaurant locations in user handleUserLocations")
        regionUpdatedExpectation.expectedFulfillmentCount = 1
        regionUpdatedExpectation.assertForOverFulfill = true
        mapViewModel.regionRelay.subscribe(onNext: { region in
                guard region != nil else {
                    return
                }
                regionUpdatedExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        let loadingTitleExpectation = XCTestExpectation(description: "The view model updates the title to loading before fetching restaurant locations in handleUserLocations")
        // Value should start as loading as well, so should be fulfilled twice
        loadingTitleExpectation.expectedFulfillmentCount = 2
        let loadedTitleExpectation = XCTestExpectation(description: "The view model updates the title to loaded after fetching restaurant locations in handleUserLocations")
        mapViewModel.titleRelay.subscribe(onNext: { title in
                if title == "Loading..." {
                    loadingTitleExpectation.fulfill()
                }
                else if title == "Loaded (\(userLocation.coordinate.latitude), \(userLocation.coordinate.longitude))" {
                    loadedTitleExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        mapViewModel.handleUserLocations([CLLocation(latitude: 200, longitude: 210), userLocation])
        wait(for: [fetchRestaurantsExpectation, regionUpdatedExpectation, loadingTitleExpectation, loadedTitleExpectation], timeout: 1)
    }
    
    func testFetchBasedOnUserLocationsFailure() {
        apiManager.failResponse = true
        let userLocation = CLLocation(latitude: 10, longitude: 11)
        let fetchRestaurantsExpectation = XCTestExpectation(description: "The view model fetches restaurants based on the user's current location with default radius of 100 when 'handleUserLocations' is called")
        apiManager.onFetchRestaurants = { coordinate, radius in
            fetchRestaurantsExpectation.fulfill()
        }
        mapViewModel.regionRelay.subscribe(
            onNext: { region in
                guard region != nil else {
                    return
                }
                XCTFail("Unexpected update of regionRelay from handleUserLocations")
            })
            .disposed(by: disposeBag)
        let failedTitleExpectation = XCTestExpectation(description: "The view model updates the title to failed after failing to fetch restaurant locations in handleUserLocations")
        mapViewModel.titleRelay.subscribe(
            onNext: { title in
                if title == "Failed to load" {
                    failedTitleExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        mapViewModel.handleUserLocations([CLLocation(latitude: 200, longitude: 210), userLocation])
        wait(for: [fetchRestaurantsExpectation, failedTitleExpectation], timeout: 1)
    }
    
    // MARK: - handleMapRegionChange
    
    func testHandleMapRegionChangeSuccess() {
        let center = CLLocationCoordinate2D(latitude: 1.5, longitude: 0.1)
        let meterSpan: CLLocationDistance = 100
        let mapRegion = MKCoordinateRegion(center: center, latitudinalMeters: meterSpan, longitudinalMeters: meterSpan)
        
        let fetchRestaurantsExpectation = XCTestExpectation(description: "The view model fetches restaurants based on the current map when 'handleMapRegionChange' is called")
        apiManager.onFetchRestaurants = { coordinate, radius in
            XCTAssertEqual(coordinate.latitude, center.latitude)
            XCTAssertEqual(coordinate.longitude, center.longitude)
            XCTAssertEqual(radius.rounded(.towardZero), meterSpan/2)
            fetchRestaurantsExpectation.fulfill()
        }
        mapViewModel.regionRelay.subscribe(onNext: { region in
                guard region != nil else {
                    return
                }
                XCTFail("Unexpected update of regionRelay from call to handleMapRegionChange")
            })
            .disposed(by: disposeBag)
        let loadingTitleExpectation = XCTestExpectation(description: "The view model updates the title to loading before fetching restaurant locations in user location handling when location manager state is allowed")
        // Value should start as loading as well, so should be fulfilled twice
        loadingTitleExpectation.expectedFulfillmentCount = 2
        let loadedTitleExpectation = XCTestExpectation(description: "The view model updates the title to loaded after fetching restaurant locations in user location handling when location manager state is allowed")
        mapViewModel.titleRelay.subscribe(onNext: { title in
                if title == "Loading..." {
                    loadingTitleExpectation.fulfill()
                }
                else if title == "Loaded (\(center.latitude), \(center.longitude))" {
                    loadedTitleExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        mapViewModel.handleMapRegionChange(mapRegion)
        wait(for: [fetchRestaurantsExpectation, loadingTitleExpectation, loadedTitleExpectation], timeout: 1)
    }
    
    func testHandleMapRegionChangeFailure() {
        apiManager.failResponse = true
        let center = CLLocationCoordinate2D(latitude: 1.5, longitude: 0.1)
        let meterSpan: CLLocationDistance = 100
        let mapRegion = MKCoordinateRegion(center: center, latitudinalMeters: meterSpan, longitudinalMeters: meterSpan)

        let fetchRestaurantsExpectation = XCTestExpectation(description: "The view model fetches restaurants based on the current map when 'handleMapRegionChange' is called")
        apiManager.onFetchRestaurants = { coordinate, radius in
            fetchRestaurantsExpectation.fulfill()
        }
        mapViewModel.regionRelay.subscribe(
            onNext: { region in
                guard region != nil else {
                    return
                }
                XCTFail("Unexpected update of regionRelay from call to handleMapRegionChange")
            })
            .disposed(by: disposeBag)
        let failedTitleExpectation = XCTestExpectation(description: "The view model updates the title to failed after failing to fetch restaurant locations in handleMapRegionChange")
        mapViewModel.titleRelay.subscribe(
            onNext: { title in
                if title == "Failed to load" {
                    failedTitleExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        mapViewModel.handleMapRegionChange(mapRegion)
        wait(for: [fetchRestaurantsExpectation, failedTitleExpectation], timeout: 1)
    }
        
    // MARK: - handleViewDidDisappear
    
    func testCompleteIfUnusedCalled() {
        mapViewModel.delegate = self
        let completeIfUnusedExpectation = XCTestExpectation(description: "completeIfUnused is called on delegate from handleViewDidDisappear")
        onCompleteIfUnused = {
            completeIfUnusedExpectation.fulfill()
        }
        mapViewModel.handleViewDidDisappear()
        wait(for: [completeIfUnusedExpectation], timeout: 1)
    }
    
    // MARK: - handleAnnotationViewSelection
    
    func testHandleAnnotationViewSelection() {
        mapViewModel.delegate = self
        let restaurantID = "TestRestID"
        let showDetailsExpectation = XCTestExpectation(description: "showDetailsForRestaurant is called on delegate from handleAnnotationViewSelection")
        onShowDetailsForRestaurant = { id in
            showDetailsExpectation.fulfill()
            XCTAssertEqual(restaurantID, id)
        }
        let annotationView = RestaurantAnnotationView(annotation: RestaurantAnnotation(restaurantLocation: RestaurantLocation(id: restaurantID, lat: 0, lng: 0, name: "")), reuseIdentifier: RestaurantAnnotationView.reuseIdentifier)
        mapViewModel.handleAnnotationViewSelection(annotationView, inMap: MKMapView())
        wait(for: [showDetailsExpectation], timeout: 1)
    }
}

extension MapViewModelTests: MapViewModelDelegate {
    func showDetailsForRestaurant(withId id: String) {
        onShowDetailsForRestaurant?(id)
    }
    
    func completeIfUnused() {
        onCompleteIfUnused?()
    }
}
