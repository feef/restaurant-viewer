//
//  JSONReader.swift
//  RestaurantViewerTests
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

struct JSONReader {
    static func dataFromFile(named filename: String) throws -> Data {
        guard let path = Bundle.allBundles.compactMap({ $0.path(forResource: filename, ofType: "json") }).first else {
            throw ReadError.fileNotFound(filename)
        }
        return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }
    
    static func decodableFromFile<Object: Decodable>(named filename: String) throws -> Object {
        return try JSONDecoder().decode(Object.self, from: dataFromFile(named: filename))
    }
}

extension JSONReader {
    enum ReadError: Error {
        case fileNotFound(String)
    }
}
