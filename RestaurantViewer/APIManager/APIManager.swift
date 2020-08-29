//
//  APIManager.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import RxSwift
import CoreLocation

protocol APIManager {
    func fetchRestaurants(aroundCoordinate coordinate: CLLocationCoordinate2D, withRadius radius: Double) -> Observable<[RestaurantLocation]>
    func fetchRestaurant(forID id: String) -> Observable<RestaurantDetails>
}
