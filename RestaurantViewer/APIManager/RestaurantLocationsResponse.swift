//
//  RestaurantLocationsResponse.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

struct RestaurantLocationsResponse: Decodable {
    let restaurantLocations: [RestaurantLocation]
    
    init(from decoder: Decoder) throws {
        let rawResponse = try RawResponse(from: decoder)
        restaurantLocations = rawResponse.response.venues
    }
}

fileprivate struct RawResponse: Decodable {
    struct Response: Decodable {
        let venues: [RestaurantLocation]
    }
    let response: Response
}
