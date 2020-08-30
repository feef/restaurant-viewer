//
//  DetailsListViewModel.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import RxSwift
import RxRelay

protocol DetailsListViewModelDelegate: class {
    func completeIfUnused()
}

class DetailsListViewModel {
    let titleRelay = BehaviorRelay<String>(value: Constants.loadingText)
    let cellsRelay = BehaviorRelay<[String]>(value: [])
    
    private let disposeBag = DisposeBag()
    private let apiManager: APIManager
    private let restaurantID: String
    
    weak var delegate: DetailsListViewModelDelegate?
    
    init(delegate: DetailsListViewModelDelegate?, apiManager: APIManager, restaurantID: String) {
        self.delegate = delegate
        self.apiManager = apiManager
        self.restaurantID = restaurantID
    }
}

// MARK: - Lifecycle

extension DetailsListViewModel {
    func handleViewDidLoad() {
        fetchRestaurant()
    }
    
    func handleViewDidDisappear() {
        delegate?.completeIfUnused()
    }
}

// MARK: - Private

extension DetailsListViewModel {
    private func fetchRestaurant() {
        titleRelay.accept("Loading...")
        apiManager.fetchRestaurant(forID: restaurantID).subscribe(
                onNext: { [weak self] restaurantDetails in
                    let details: [String: Any?] = [
                        "Address": restaurantDetails.address,
                        "Description": restaurantDetails.description,
                        "Rating": restaurantDetails.rating,
                        "Hours": restaurantDetails.hours,
                        "Menu": restaurantDetails.menuURL,
                        "Webpage": restaurantDetails.url
                    ]
                    
                    let displayTexts: [String] = details.compactMap {
                        guard let value = $0.value else {
                            return nil
                        }
                        return "\($0.key): \(value)"
                    }
                    self?.cellsRelay.accept(displayTexts)
                    self?.titleRelay.accept(restaurantDetails.name)
                },
                onError: { [weak self] _ in
                    self?.titleRelay.accept(Constants.failedToLoadText)
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK:  - Internal types

extension DetailsListViewModel {
    struct Constants {
        static let failedToLoadText = "Failed to load"
        static let loadingText = "Loading..."
    }
}
