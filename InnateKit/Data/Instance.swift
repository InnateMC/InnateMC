//
//  Instance.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/18/22.
//

import Foundation

public class Instance: Codable {
    public var path: URL?
    public var name: String
    // Minecraft version to use for assets index
    public var assetIndex: String
    // List of relative paths in the Libraries directory
    public var libraries: [String]
    public var mainClass: String
    public var minecraftJar: String
    
    public init(path: URL?, name: String, assetIndex: String, libraries: [String], mainClass: String, minecraftJar: String) {
        self.path = path
        self.name = name
        self.assetIndex = assetIndex
        self.libraries = libraries
        self.mainClass = mainClass
        self.minecraftJar = minecraftJar
    }
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
        return try deserialize(FileHandler.getData(url.appendingPathComponent("Instance.plist"))!, path: url)
    }

    public static func loadInstances() throws -> [Instance] {
        let appSupportFolder = try FileHandler.getOrCreateFolder()
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
            let instanceFolder = FileHandler.instancesFolder.appendingPathComponent("name")
            if FileManager.default.fileExists(atPath: instanceFolder.path) {
                continue
            }
            try FileManager.default.createDirectory(at: instanceFolder, withIntermediateDirectories: true, attributes: nil)
            let instance = Instance(
                path: instanceFolder,
                name: name,
                assetIndex: "1.18.2",
                libraries: ["e", "e2"],
                mainClass: "",
                minecraftJar: "bruh.jar"
            )
            let instancePlist = instanceFolder.appendingPathComponent("Instance.plist")
            let data = try instance.serialize()
            try FileHandler.saveData(instancePlist, data)
        }
    }
}
#endif
