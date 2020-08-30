//
//  PrivateConstants.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/30/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

class PrivateConstants {
    static let shared = try! PrivateConstants()
    
    let clientID: String
    let clientSecret: String
    
    private init() throws {
        let dictionary = try PlistReader.plistContentsFromFile(named: "PrivateConstants")
        guard
            let clientID = dictionary["clientID"] as? String,
            let clientSecret = dictionary["clientSecret"] as? String
        else {
            throw InitError.invalidPlistContents(dictionary)
        }
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
}

extension PrivateConstants {
    enum InitError: Error {
        case invalidPlistContents([String: Any])
    }
}
