//
//  RestaurantDetailsTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
@testable import RestaurantViewer

class RestaurantDetailsTests: XCTestCase {
    func testSuccessfulParsing() {
        do {
            let details: RestaurantDetails = try JSONReader.decodableFromFile(named: "RestaurantDetails")
            XCTAssertEqual(details.address, "59th St to 110th St")
            XCTAssertEqual(details.description, "Central Park is the 843-acre green heart of Manhattan and is maintained by the Central Park Conservancy. It was designed in the 19th century by Frederick Law Olmsted and Calvert Vaux as an urban escape for New Yorkers, and now receives over 40 million visits per year.")
            XCTAssertEqual(details.hours, "Open until 1:00 AM")
            XCTAssertEqual(details.id, "412d2800f964a520df0c1fe3")
            XCTAssertEqual(details.lat, 40.78408342593807)
            XCTAssertEqual(details.lng, -73.96485328674316)
            XCTAssertEqual(details.menuURL, URL(string: "http://www.mobileMenuURL.com"))
            XCTAssertEqual(details.name, "Central Park")
            XCTAssertEqual(details.rating, 9.8)
            XCTAssertEqual(details.url, URL(string: "http://www.centralparknyc.org"))
        }
        catch {
            XCTFail("Failed to parse RestaurantDetails from file. Encountered error: \(error)")
        }
    }
    
    func testFailedParsing() {
        XCTAssertThrowsError(try JSONReader.decodableFromFile(named: "Empty") as RestaurantDetails) { error in
            XCTAssertNotNil(error as? DecodingError)
        }
    }
}
