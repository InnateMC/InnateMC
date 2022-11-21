//
//  Instance.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/18/22.
//

import Foundation

public struct Instance: Codable {
    public var path: URL?
    public var name: String
    // Minecraft version to use for assets index
    public var version: String
}

extension Instance {
    public func serialize() throws -> Data {
        let encoder = PropertyListEncoder()
        return try encoder.encode(self)
    }
    
    internal static func deserialize(_ data: Data, path: URL) throws -> Instance {
        let decoder = PropertyListDecoder()
        return try decoder.decode(Instance.self, from: data)
    }

    public static func loadFromDirectory(_ url: URL) throws -> Instance {
        let plistUrl = url.appendingPathComponent("Instance.plist")
        return try deserialize(try Data(contentsOf: plistUrl), path: url)
    }
}
