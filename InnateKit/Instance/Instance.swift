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
    public var assetIndex: PartialAssetIndex
    // List of relative paths in the Libraries directory
    public var libraries: [Library]
    public var mainClass: String
    public var minecraftJar: MinecraftJar
    public var isStarred: Bool
    public var logo: String

    public init(name: String, assetIndex: PartialAssetIndex, libraries: [Library], mainClass: String, minecraftJar: MinecraftJar, isStarred: Bool, logo: String) {
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

    public func getMcJarPath() -> URL {
        return getPath().appendingPathComponent("minecraft.jar")
    }
}

public class MinecraftJar: Codable {
    public let type: FileType
    public let url: String?
    public let sha1: String?
    
    public init(type: FileType, url: String?, sha1: String?) {
        self.type = type
        self.url = url
        self.sha1 = sha1
    }
}

public class Library: Codable {
    public let type: FileType
    public let path: String
    public let url: String?
    public let sha1: String?

    public init(type: FileType, path: String, url: String?, sha1: String?) {
        self.type = type
        self.path = path
        self.url = url
        self.sha1 = sha1
    }

    public func getAbsolutePath() -> URL {
        return FileHandler.librariesFolder.appendingPathComponent(self.path, isDirectory: true)
    }
    
    public func asDownloadTask() -> DownloadTask {
        return DownloadTask(url: URL(string: url!)!, filePath: self.getAbsolutePath(), sha1: self.sha1)
    }
}

public class PartialAssetIndex: Codable {
    public let id: String
    public let sha1: String
    public let url: String
    
    public init(id: String, sha1: String, url: String) {
        self.id = id
        self.sha1 = sha1
        self.url = url
    }
}

public enum FileType: Codable, CaseIterable {
    case remote
    case local
}

extension Instance {
    func serialize() throws -> Data {
        let encoder = PropertyListEncoder()
        return try encoder.encode(self)
    }
    
    internal static func deserialize(_ data: Data, path: URL) throws -> Instance {
        let decoder = PropertyListDecoder()
        return try decoder.decode(Instance.self, from: data)
    }

    static func loadFromDirectory(_ url: URL) throws -> Instance {
        return try deserialize(FileHandler.getData(url.appendingPathComponent("Instance.plist"))!, path: url)
    }

    static func loadInstances() throws -> [Instance] {
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

    func downloadMcJar() throws -> DownloadProgress {
        if (self.minecraftJar.type == .local) {
            return DownloadProgress.completed()
        }
        return ParallelDownloader.download([DownloadTask(url: URL(string: self.minecraftJar.url!)!, filePath: self.getMcJarPath(), sha1: self.minecraftJar.sha1)], progress: DownloadProgress())
    }

    func downloadLibs() -> DownloadProgress {
        var tasks: [DownloadTask] = []
        for library in libraries {
            if library.type == .local {
                continue
            }
            tasks.append(library.asDownloadTask())
        }
        return ParallelDownloader.download(tasks, progress: DownloadProgress())
    }
    
    func downloadAssets() throws -> DownloadProgress {
        let index = try AssetIndex.get(version: self.assetIndex.id, urlStr: self.assetIndex.url)
        return try index.downloadParallel()
    }

    func createAsNewInstance() throws {
        let instancePath = getPath()
        let fm = FileManager.default
        if fm.fileExists(atPath: instancePath.path) {
            try fm.removeItem(at: instancePath)
        }
        try fm.createDirectory(at: instancePath, withIntermediateDirectories: true)
        try FileHandler.saveData(instancePath.appendingPathComponent("Instance.plist"), serialize())
    }
}
