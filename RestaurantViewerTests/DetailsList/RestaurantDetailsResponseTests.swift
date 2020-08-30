//
//  RestaurantDetailsResponseTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
@testable import RestaurantViewer

class RestaurantDetailsResponseTests: XCTestCase {
    func testSuccessfulParsing() {
        do {
            let response: RestaurantDetailsResponse = try JSONReader.decodableFromFile(named: "RestaurantDetailsResponse")
            XCTAssertEqual(response.restaurantDetails.id, "4d54daecba5b224b50ff0714")
        }
        catch {
            XCTFail("Failed to parse RestaurantDetailsResponse from file. Encountered error: \(error)")
        }
    }
    
    func testFailedParsing() {
        XCTAssertThrowsError(try JSONReader.decodableFromFile(named: "Empty") as RestaurantDetailsResponse) { error in
            XCTAssertNotNil(error as? DecodingError)
        }
    }
}
