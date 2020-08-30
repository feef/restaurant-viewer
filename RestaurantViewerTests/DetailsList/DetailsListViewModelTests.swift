//
//  DetailsListViewModelTests.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/30/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import XCTest
import RxSwift
@testable import RestaurantViewer

class DetailsListViewModelTests: XCTestCase {
    let restaurantID = "TestRestID"
    var apiManager: LocalAPIManager!
    var disposeBag: DisposeBag!
    var detailsListViewModel: DetailsListViewModel!
    private var onCompleteIfUnused: (() -> Void)?
    
    override func setUp() {
        apiManager = LocalAPIManager()
        disposeBag = DisposeBag()
        detailsListViewModel = DetailsListViewModel(delegate: nil, apiManager: apiManager, restaurantID: restaurantID)
    }
    
    override func tearDown() {
        apiManager = nil
        disposeBag = nil
        detailsListViewModel = nil
        onCompleteIfUnused = nil
    }
    
    // MARK: - handleViewDidLoad
    
    func testDetailsFetchSuccess() {
        let cellsExpectation = XCTestExpectation(description: "CellsRelay is updated after fetch of restaurant details in handleViewDidLoad")
        detailsListViewModel.cellsRelay.subscribe(
            onNext: { texts in
                guard !texts.isEmpty else {
                    return
                }
                cellsExpectation.fulfill()
                XCTAssertEqual(texts, ["Address: Kometensingel 52-54", "Description: Unknown", "Hours: Unknown", "Menu: Unknown", "Rating: Unknown", "Webpage: Unknown"])
            })
            .disposed(by: disposeBag)
        let loadingTitleExpectation = XCTestExpectation(description: "TitleRelay is updated to loading before fetch of restaurant details in handleViewDidLoad")
        loadingTitleExpectation.expectedFulfillmentCount = 2
        let nameTitleExpectation = XCTestExpectation(description: "TitleRelay is updated to restaurant name after fetch of restaurant details in handleViewDidLoad")
        detailsListViewModel.titleRelay.subscribe(
            onNext: { title in
                if title == "Loading..." {
                    loadingTitleExpectation.fulfill()
                }
                else if title == "RK Basisschool De Satelliet" {
                    nameTitleExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        let fetchExpectation = XCTestExpectation(description: "fetchRestaurant is called with provided restaurant ID from handleViewDidLoad")
        apiManager.onFetchRestaurant = { restaurantID in
            fetchExpectation.fulfill()
            XCTAssertEqual(restaurantID, self.restaurantID)
        }
        detailsListViewModel.handleViewDidLoad()
        wait(for: [cellsExpectation, loadingTitleExpectation, nameTitleExpectation, fetchExpectation], timeout: 1)
    }
    
    func testDetailsFetchFailure() {
        apiManager.failResponse = true
        detailsListViewModel.cellsRelay.subscribe(
            onNext: { texts in
                guard !texts.isEmpty else {
                    return
                }
                XCTFail("Unexpected update of cellsRelay from handleViewDidLoad")
            })
            .disposed(by: disposeBag)
        let loadingTitleExpectation = XCTestExpectation(description: "TitleRelay is updated to loading before fetch of restaurant details in handleViewDidLoad")
        loadingTitleExpectation.expectedFulfillmentCount = 2
        let failedTitleExpectation = XCTestExpectation(description: "TitleRelay is updated to failed after failed fetch of restaurant details in handleViewDidLoad")
        detailsListViewModel.titleRelay.subscribe(
            onNext: { title in
                if title == "Loading..." {
                    loadingTitleExpectation.fulfill()
                }
                else if title == "Failed to load" {
                    failedTitleExpectation.fulfill()
                }
            })
            .disposed(by: disposeBag)
        detailsListViewModel.handleViewDidLoad()
        wait(for: [loadingTitleExpectation, failedTitleExpectation], timeout: 1)
    }
    
    // MARK: - handleViewDidDisappear
    
    func testCompleteIfUnusedCalled() {
        detailsListViewModel.delegate = self
        let completeIfUnusedExpectation = XCTestExpectation(description: "completeIfUnused is called on delegate from handleViewDidDisappear")
        onCompleteIfUnused = {
            completeIfUnusedExpectation.fulfill()
        }
        detailsListViewModel.handleViewDidDisappear()
        wait(for: [completeIfUnusedExpectation], timeout: 1)
    }
}

// MARK: - DetailsListViewModelDelegate

extension DetailsListViewModelTests: DetailsListViewModelDelegate {
    func completeIfUnused() {
        onCompleteIfUnused?()
    }
}
