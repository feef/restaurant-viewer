//
//  RestaurantAnnotation.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import MapKit

class RestaurantAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(restaurantLocation: RestaurantLocation) {
        coordinate = CLLocationCoordinate2D(latitude: restaurantLocation.lat, longitude: restaurantLocation.lng)
    }
}
