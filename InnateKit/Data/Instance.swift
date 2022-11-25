//
// Copyright © 2022 Shrish Deshpande
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class Instance: Codable {
    public var name: String
    // Minecraft version to use for assets index
    public var assetIndex: String
    // List of relative paths in the Libraries directory
    public var libraries: [String]
    public var mainClass: String
    public var minecraftJar: String
    public var isStarred: Bool
    public var logo: String
    
    public init(name: String, assetIndex: String, libraries: [String], mainClass: String, minecraftJar: String, isStarred: Bool, logo: String) {
        self.name = name
        self.assetIndex = assetIndex
        self.libraries = libraries
        self.mainClass = mainClass
        self.minecraftJar = minecraftJar
        self.isStarred = isStarred
        self.logo = logo
    }
    
    public func getPath() -> URL {
        return FileHandler.instancesFolder.appendingPathComponent(self.name + ".innate", isDirectory: true)
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
                name: name,
                assetIndex: "1.18.2",
                libraries: ["e", "e2"],
                mainClass: "",
                minecraftJar: "bruh.jar",
                isStarred: name.hasSuffix("2"),
                logo: "test.png"
            )
            let instancePlist = instanceFolder.appendingPathComponent("Instance.plist")
            let data = try instance.serialize()
            try FileHandler.saveData(instancePlist, data)
        }
    }
}
#endif
