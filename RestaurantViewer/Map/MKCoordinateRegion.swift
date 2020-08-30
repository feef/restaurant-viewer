//
//  MKCoordinateRegion.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/30/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import MapKit

extension MKCoordinateRegion: Equatable {
    public static func ==(lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return
            lhs.center.latitude == rhs.center.latitude &&
            lhs.center.longitude == rhs.center.longitude &&
            lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
            lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
