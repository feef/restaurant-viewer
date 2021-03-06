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
    let restaurantID: String
    let title: String?
    
    init(restaurantLocation: RestaurantLocation) {
        coordinate = CLLocationCoordinate2D(latitude: restaurantLocation.lat, longitude: restaurantLocation.lng)
        restaurantID = restaurantLocation.id
        title = restaurantLocation.name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let annotation = object as? RestaurantAnnotation else {
            return false
        }
        return
            coordinate.latitude == annotation.coordinate.latitude &&
            coordinate.longitude == annotation.coordinate.longitude &&
            restaurantID == annotation.restaurantID &&
            title == annotation.title
    }
}
