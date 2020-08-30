//
//  FoursquareAPIManager.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/30/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import RxSwift
import CoreLocation

class FoursquareAPIManager: APIManager {
    static let shared: FoursquareAPIManager = {
        let privateConstants = PrivateConstants.shared
        return FoursquareAPIManager(clientID: privateConstants.clientID, clientSecret: privateConstants.clientSecret)
    }()
    
    private let clientIDQueryItem: URLQueryItem
    private let clientSecretQueryItem: URLQueryItem
    private let versionQueryItem = URLQueryItem(name: "v", value: "20200830")
        
    init(clientID: String, clientSecret: String) {
        clientIDQueryItem = URLQueryItem(name: "client_id", value: clientID)
        clientSecretQueryItem = URLQueryItem(name: "client_secret", value: clientSecret)
    }
    
    func fetchRestaurants(aroundCoordinate coordinate: CLLocationCoordinate2D, withRadius radius: Double) -> Observable<[RestaurantLocation]> {
        let path = "/venues/search"
        let coordinateQueryItem = URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)")
        let radiusQueryItem = URLQueryItem(name: "radius", value: "\(Int(radius))")
        let categoryQueryItem = URLQueryItem(name: "categoryId", value: "4d4b7105d754a06374d81259")
        let components = urlComponents(withPath: path, queryItems: [coordinateQueryItem, radiusQueryItem, categoryQueryItem])
        guard let url = components.url else {
            return Single.error(Error.InvalidURL(components)).asObservable()
        }
        return URLSession.shared.rx.response(request: URLRequest(url: url)).map({ response, data in
            guard response.statusCode == 200 else {
                throw Error.InvalidResponse(response)
            }
            return try JSONDecoder().decode(RestaurantLocationsResponse.self, from: data).restaurantLocations
        })
        .asObservable()
    }
    
    func fetchRestaurant(forID id: String) -> Observable<RestaurantDetails> {
        let path = "/venues/\(id)"
        let components = urlComponents(withPath: path)
        guard let url = components.url else {
            return Single.error(Error.InvalidURL(components)).asObservable()
        }
        return URLSession.shared.rx.response(request: URLRequest(url: url)).map({ response, data in
            guard response.statusCode == 200 else {
                throw Error.InvalidResponse(response)
            }
            return try JSONDecoder().decode(RestaurantDetailsResponse.self, from: data).restaurantDetails
        })
        .asObservable()
    }
}

extension FoursquareAPIManager {
    func urlComponents(withPath path: String, queryItems: [URLQueryItem] = []) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.foursquare.com"
        components.path = "/v2" + path
        components.queryItems = [clientIDQueryItem, clientSecretQueryItem, versionQueryItem]
        queryItems.forEach { components.queryItems?.append($0) }
        return components
    }
}

extension FoursquareAPIManager {
    private enum Error: Swift.Error {
        case InvalidResponse(HTTPURLResponse), InvalidURL(URLComponents)
    }
}
