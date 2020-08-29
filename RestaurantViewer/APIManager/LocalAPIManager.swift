//
//  LocalAPIManager.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import RxSwift
import CoreLocation

class LocalAPIManager: APIManager {    
    var failResponse = false
    
    func fetchRestaurants(aroundCoordinate coordinate: CLLocationCoordinate2D, withRadius radius: Double) -> Observable<[RestaurantLocation]> {
        return Single<[RestaurantLocation]>.create { single in
            do {
                let response: RestaurantLocationsResponse = try JSONReader.decodableFromFile(named: !self.failResponse ? "RestaurantLocationsResponse" : "Empty")
                single(.success(response.restaurantLocations))
            }
            catch {
                single(.error(error))
            }
            return Disposables.create()
        }
        .asObservable()
    }
    
    func fetchRestaurant(forID id: String) -> Observable<RestaurantDetails> {
        return Single<RestaurantDetails>.create { single in
            do {
                let response: RestaurantDetailsResponse = try JSONReader.decodableFromFile(named: !self.failResponse ? "RestaurantDetailsResponse" : "Empty")
                single(.success(response.restaurantDetails))
            }
            catch {
                single(.error(error))
            }
            return Disposables.create()
        }
        .asObservable()
    }
}
