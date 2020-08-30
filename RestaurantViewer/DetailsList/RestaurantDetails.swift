//
//  RestaurantDetails.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

struct RestaurantDetails: Codable {
    let address: String?
    let description: String?
    let hours: String?
    let id: String
    let lat: Double
    let lng: Double
    let menuURL: URL?
    let name: String
    let rating: Double?
    let url: URL?
    
    init(from decoder: Decoder) throws {
        let rawResponse = try RawResponse(from: decoder)
        address = rawResponse.location.address
        description = rawResponse.description
        hours = rawResponse.hours?.status
        id = rawResponse.id
        lat = rawResponse.location.lat
        lng = rawResponse.location.lng
        menuURL = rawResponse.menu?.mobileUrl
        name = rawResponse.name
        rating = rawResponse.rating
        url = rawResponse.url
    }
}

fileprivate struct RawResponse: Decodable {
    struct Location: Decodable {
        let lat: Double
        let lng: Double
        let address: String?
    }
    
    struct Menu: Decodable {
        let mobileUrl: URL
    }
    
    struct Hours: Decodable {
        let status: String
    }
    
    let description: String?
    let hours: Hours?
    let id: String
    let location: Location
    let menu: Menu?
    let name: String
    let rating: Double?
    let url: URL?
}

