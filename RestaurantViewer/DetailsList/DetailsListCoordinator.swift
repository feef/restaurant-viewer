//
//  DetailsListCoordinator.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit

class DetailsListCoordinator {
    private let apiManager: APIManager
    private let navigationController: UINavigationController
    private let restaurantID: String
    
    private lazy var viewModel = DetailsListViewModel(delegate: self, apiManager: apiManager, restaurantID: restaurantID)
    private var childCoordinators = [Coordinator]()
    private var viewController: UIViewController!
    
    var parent: Coordinator?
    
    init(navigationController: UINavigationController, restaurantID: String, apiManager: APIManager = FoursquareAPIManager.shared) {
        self.apiManager = apiManager
        self.navigationController = navigationController
        self.restaurantID = restaurantID
    }
}

// MARK: - Coordinator

extension DetailsListCoordinator: Coordinator {
    func childCompleted(_ child: Coordinator) {
        childCoordinators.removeAll() { child === $0 }
    }
    
    func start() {
        let detailsNavigationController = UINavigationController(rootViewController: DetailsListViewController(viewModel: viewModel))
        navigationController.present(detailsNavigationController, animated: true)
        viewController = detailsNavigationController
    }
}

// MARK: - ViewModel-facing

extension DetailsListCoordinator: DetailsListViewModelDelegate {
    func completeIfUnused() {
        guard !navigationController.viewControllers.contains(viewController) else {
            return
        }
        parent?.childCompleted(self)
    }
}
