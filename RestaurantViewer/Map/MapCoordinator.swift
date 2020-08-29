//
//  MapCoordinator.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit

class MapCoordinator {
    private let apiManager: APIManager
    private let locationManager: LocationManager
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController, apiManager: APIManager = LocalAPIManager(), locationManager: LocationManager = UserLocationManager()) {
        self.navigationController = navigationController
        self.apiManager = apiManager
        self.locationManager = locationManager
    }
}

// MARK: - Coordinator

extension MapCoordinator: Coordinator {
    func start() {
        let mapViewController = MapViewController(viewModel: MapViewModel(apiManager: apiManager, locationManager: locationManager))
        navigationController.pushViewController(mapViewController, animated: true)
    }
}
