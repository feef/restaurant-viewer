//
//  MapCoordinator.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit

class MapCoordinator: Coordinator {
    private let apiManager: APIManager
    private let locationManager: LocationManager
    private let navigationController: UINavigationController
    
    private lazy var viewModel = MapViewModel(delegate: self, apiManager: apiManager, locationManager: locationManager)
    private var childCoordinators = [Coordinator]()
    private var viewController: UIViewController!
    
    var parent: Coordinator?
    
    init(navigationController: UINavigationController, apiManager: APIManager = LocalAPIManager(), locationManager: LocationManager = UserLocationManager()) {
        self.navigationController = navigationController
        self.apiManager = apiManager
        self.locationManager = locationManager
    }
}

// MARK: - Coordinator

extension MapCoordinator {
    func childCompleted(_ child: Coordinator) {
        childCoordinators.removeAll() { child === $0 }
    }
    
    func start() {
        let mapViewController = MapViewController(viewModel: viewModel)
        navigationController.pushViewController(mapViewController, animated: true)
        viewController = mapViewController
    }
}

// MARK: - ViewModel-facing

extension MapCoordinator: MapViewModelDelegate {
    func showDetailsForRestaurant(withId id: String) {
        let detailsListCoordinator = DetailsListCoordinator(navigationController: navigationController, restaurantID: id)
        detailsListCoordinator.start()
        detailsListCoordinator.parent = self
        childCoordinators.append(detailsListCoordinator)
    }
    
    func completeIfUnused() {
        guard !navigationController.viewControllers.contains(viewController) else {
            return
        }
        parent?.childCompleted(self)
    }
}
