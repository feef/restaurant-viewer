//
//  RestaurantLocationsResponseTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
@testable import RestaurantViewer

class RestaurantLocationsResponseTests: XCTestCase {
    func testSuccessfulParsing() {
        do {
            let response: RestaurantLocationsResponse = try JSONReader.decodableFromFile(named: "RestaurantLocationsResponse")
            XCTAssertEqual(response.restaurantLocations.count, 30)
        }
        catch {
            XCTFail("Failed to parse RestaurantLocationsResponse from file. Encountered error: \(error)")
        }
    }
    
    func testFailedParsing() {
        XCTAssertThrowsError(try JSONReader.decodableFromFile(named: "Empty") as RestaurantLocationsResponse) { error in
            XCTAssertNotNil(error as? DecodingError)
        }
    }
}
