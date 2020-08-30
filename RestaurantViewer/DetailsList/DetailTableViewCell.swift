//
//  DetailTableViewCell.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: self)
    
    var model: String? {
        didSet {
            textLabel?.text = model
        }
    }
}
