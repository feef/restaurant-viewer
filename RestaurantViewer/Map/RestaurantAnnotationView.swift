//
//  RestaurantAnnotationView.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import MapKit

class RestaurantAnnotationView: MKMarkerAnnotationView {
    static let reuseIdentifier = String(describing: self)
    
    override var annotation: MKAnnotation? {
        willSet {
            if let _ = annotation {
                displayPriority = .required
            }
        }
    }    
}
