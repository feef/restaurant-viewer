//
//  PlistReader.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/30/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import Foundation

public struct PlistReader {
    static func plistContentsFromFile(named fileName: String) throws -> [String: Any] {
        guard
            let fileURL = Bundle.allBundles.first(where: { $0.url(forResource: fileName, withExtension: "plist") != nil })?.url(forResource: fileName, withExtension: "plist"),
            let data = try? Data(contentsOf: fileURL),
            let plistDictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else {
            throw ReadError.fileNotFound(fileName)
        }
        return plistDictionary
    }
}

extension PlistReader {
    enum ReadError: Error {
        case fileNotFound(String)
    }
}
