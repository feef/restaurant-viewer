//
//  Coordinator.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    var parent: Coordinator? { get set }
    func childCompleted(_ child: Coordinator)
    func start()
}
