//
//  RestaurantDetailsResponse.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

struct RestaurantDetailsResponse: Decodable {
    let restaurantDetails: RestaurantDetails
    
    init(from decoder: Decoder) throws {
        let rawResponse = try RawResponse(from: decoder)
        restaurantDetails = rawResponse.response.venue
    }
}

fileprivate struct RawResponse: Decodable {
    struct Response: Decodable {
        let venue: RestaurantDetails
    }
    let response: Response
}
