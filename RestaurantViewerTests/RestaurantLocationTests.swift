//
//  RestaurantLocationTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
@testable import RestaurantViewer

class RestaurantLocationTests: XCTestCase {
    func testSuccessfulParsing() {
        do {
            let location: RestaurantLocation = try JSONReader.decodableFromFile(named: "RestaurantLocation")
            XCTAssertEqual(location.id, "5642aef9498e51025cf4a7a5")
            XCTAssertEqual(location.name, "Mr. Purple")
            XCTAssertEqual(location.lat, 40.72173744277209)
            XCTAssertEqual(location.lng, -73.98800687282996)
        }
        catch {
            XCTFail("Failed to parse RestaurantLocation from file. Encountered error: \(error)")
        }
    }
    
    func testFailedParsing() {
        XCTAssertThrowsError(try JSONReader.decodableFromFile(named: "Empty") as RestaurantLocation) { error in
            XCTAssertNotNil(error as? DecodingError)
        }
    }
}
