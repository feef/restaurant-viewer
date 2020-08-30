//
//  RestaurantLocation.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

struct RestaurantLocation: Codable {
    let id: String
    let lat: Double
    let lng: Double
    let name: String
    
    init(id: String, lat: Double, lng: Double, name: String) {
        self.id = id
        self.lat = lat
        self.lng = lng
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let rawResponse = try RawResponse(from: decoder)
        self.init(id: rawResponse.id, lat: rawResponse.location.lat, lng: rawResponse.location.lng, name: rawResponse.name)
    }
}

fileprivate struct RawResponse: Decodable {
    struct Location: Decodable {
        let lat: Double
        let lng: Double
    }
    
    let id: String
    let location: Location
    let name: String
}
