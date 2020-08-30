//
//  DetailsListViewController.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailsListViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let viewModel: DetailsListViewModel
    
    // MARK: - Init
    
    init(viewModel: DetailsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailsListViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: DetailTableViewCell.reuseIdentifier)
        viewModel.cellsRelay.observeOn(MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: DetailTableViewCell.reuseIdentifier, cellType: DetailTableViewCell.self)) { _, model, cell in
                cell.model = model
            }
            .disposed(by: disposeBag)
        viewModel.titleRelay.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] title in
                self.title = title
            })
            .disposed(by: disposeBag)
        viewModel.handleViewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.handleViewDidDisappear()
    }
}
