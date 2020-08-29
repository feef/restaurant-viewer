//
//  LocalAPIManagerTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
@testable import RestaurantViewer

class LocalAPIManagerTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    func testMultipleRestaurantsFetchSuccess() {
        let expectation = XCTestExpectation(description: "fetchRestaurants calls 'onNext' with response")
        LocalAPIManager().fetchRestaurants(aroundCoordinate: CLLocationCoordinate2D(), withRadius: 0)
            .subscribe(
                onNext: { restaurantLocationsResponse in
                    XCTAssertEqual(restaurantLocationsResponse.count, 30)
                    expectation.fulfill()
                },
                onError: { error in XCTFail("Unexpected call to 'onError' from fetchRestaurants. Error: \(error)") }
            )
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
    
    func testMultipleRestaurantsFetchFailure() {
        let expectation = XCTestExpectation(description: "fetchRestaurants calls 'onError' with error")
        let apiManager = LocalAPIManager()
        apiManager.failResponse = true
        apiManager.fetchRestaurants(aroundCoordinate: CLLocationCoordinate2D(), withRadius: 0)
            .subscribe(
                onNext: { restaurantLocationsResponse in
                    XCTFail("Unexpected call to 'onNext' from fetchRestaurants")
                },
                onError: { error in
                    XCTAssertNotNil(error as? DecodingError)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
    
    func testSingleRestaurantFetchSuccess() {
        let expectation = XCTestExpectation(description: "fetchRestaurant calls 'onNext' with response")
        LocalAPIManager().fetchRestaurant(forID: "")
            .subscribe(
                onNext: { restaurantDetailsResponse in
                    XCTAssertEqual(restaurantDetailsResponse.id, "4d54daecba5b224b50ff0714")
                    expectation.fulfill()
                },
                onError: { error in XCTFail("Unexpected call to 'onError' from fetchRestaurant. Error: \(error)") }
            )
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
    
    func testSingleRestaurantFetchFailure() {
        let expectation = XCTestExpectation(description: "fetchRestaurant calls 'onError' with error")
        let apiManager = LocalAPIManager()
        apiManager.failResponse = true
        apiManager.fetchRestaurants(aroundCoordinate: CLLocationCoordinate2D(), withRadius: 0)
            .subscribe(
                onNext: { restaurantLocationsResponse in
                    XCTFail("Unexpected call to 'onNext' from fetchRestaurant")
                },
                onError: { error in
                    XCTAssertNotNil(error as? DecodingError)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)
        wait(for: [expectation], timeout: 1)
    }
}
