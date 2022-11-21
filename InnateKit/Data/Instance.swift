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
    public var assetIndex: String
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
    
    public static func loadInstances() throws -> [Instance] {
        let appSupportFolder = try FolderHandler.getOrCreateFolder()
        var instances: [Instance] = []
        // Walk through directories in innateMcUrl
        let directoryContents = try FileManager.default.contentsOfDirectory(
                at: appSupportFolder,
                includingPropertiesForKeys: nil
        )
        for url in directoryContents {
            if !url.hasDirectoryPath {
                continue
            }
            if !url.lastPathComponent.hasSuffix(".innate") {
                continue
            }
            let instance = try Instance.loadFromDirectory(url)
            instances.append(instance)
        }
        return instances
    }
}

#if DEBUG
extension Instance {
    public static func createTestInstances() throws {
        let names = ["Test1", "Test2", "Test3"]
        for name in names {
            let instanceFolder = try FolderHandler.getOrCreateFolder("Instances").appendingPathComponent(name + ".innate")
            if FileManager.default.fileExists(atPath: instanceFolder.path) {
                continue
            }
            try! FileManager.default.createDirectory(at: instanceFolder, withIntermediateDirectories: true, attributes: nil)
            let instance = Instance(path: instanceFolder, name: name, assetIndex: "1.18.2")
            let instancePlist = instanceFolder.appendingPathComponent("Instance.plist")
            let data = try instance.serialize()
            try FileHandler.saveData(instancePlist, data)
        }
    }
}
#endif
