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
import SwiftUI
import Combine

private class PublishedWrapper<T> {
    @Published private(set) var value: T

    init(_ value: Published<T>) {
        _value = value
    }
}

extension Published {
    var unofficialValue: Value {
        PublishedWrapper(self).value
    }
}

extension Published: Decodable where Value: Decodable {
    public init(from decoder: Decoder) throws {
        self.init(wrappedValue: try .init(from: decoder))
    }
}

extension Published: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        try unofficialValue.encode(to: encoder)
    }
}

public class Instance: Identifiable, Hashable, InstanceData, ObservableObject {
    public var name: String
    public var assetIndex: PartialAssetIndex
    public var libraries: [Library]
    public var mainClass: String
    public var minecraftJar: MinecraftJar
    @Published public var isStarred: Bool
    public var logo: String
    public var description: String?
    public var debugString: String?
    public var someDebugString: String {
        get { return debugString ?? assetIndex.id }
        set(newValue) { self.debugString = newValue }
    }
    public var isRunning: Bool? = false
    public var lastPlayed: Date?
    public var preferences = InstancePreferences()
    
    public init(name: String,
                assetIndex: PartialAssetIndex,
                libraries: [Library],
                mainClass: String,
                minecraftJar: MinecraftJar,
                isStarred: Bool,
                logo: String,
                description: String?,
                debugString: String?
    ) {
        self.name = name
        self.assetIndex = assetIndex
        self.libraries = libraries
        self.mainClass = mainClass
        self.minecraftJar = minecraftJar
        self.isStarred = isStarred
        self.logo = logo
        self.description = description
        self.debugString = debugString
        self.isRunning = false
    }
    
    public func getPath() -> URL {
        return FileHandler.instancesFolder.appendingPathComponent(self.name + ".innate", isDirectory: true)
    }
    
    public func getMcJarPath() -> URL {
        return getPath().appendingPathComponent("minecraft.jar")
    }
    
    public func getLogoPath() -> URL {
        return FileHandler.logosFolder.appendingPathComponent(logo)
    }
    
    public func checkMatch(_ term: String) -> Bool {
        return self.name.localizedCaseInsensitiveContains(term) || self.someDebugString.localizedCaseInsensitiveContains(term)
    }
    
    public static func == (lhs: Instance, rhs: Instance) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}

public class MinecraftJar: Codable, Identifiable, InstanceData {
    public let type: FileType
    public let url: String?
    public let sha1: String?
    
    public init(type: FileType, url: String?, sha1: String?) {
        self.type = type
        self.url = url
        self.sha1 = sha1
    }
}

public class Library: Codable, Identifiable, InstanceData {
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
        return DownloadTask(url: URL(string: url!)!, filePath: self.getAbsolutePath(), sha1: self.sha1) // TODO: fix sha1 checking for libraries
    }
}

public class PartialAssetIndex: Codable, Identifiable, InstanceData {
    public let id: String
    public let sha1: String
    public let url: String
    
    public init(id: String, sha1: String, url: String) {
        self.id = id
        self.sha1 = sha1
        self.url = url
    }
}

public enum FileType: String, Codable, CaseIterable, InstanceData {
    case remote = "remote"
    case local = "local"
}

public class Arguments: Codable, Identifiable, InstanceData {
    public let game: [String]
    public let jvm: [String]
    
    public init(game: [String], jvm: [String]) {
        self.game = game
        self.jvm = jvm
    }
}

extension Instance {
    public func serialize() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
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
        var instances: [Instance] = []
        let directoryContents: [URL] = try FileManager.default.contentsOfDirectory(
            at: FileHandler.instancesFolder,
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
    
    public static func loadInstancesThrow() -> [Instance] {
        return try! loadInstances()
    }
    
    public func downloadMcJar() throws -> DownloadProgress {
        if (self.minecraftJar.type == .local) {
            return DownloadProgress.completed()
        }
        return ParallelDownloader.download([DownloadTask(url: URL(string: self.minecraftJar.url!)!, filePath: self.getMcJarPath(), sha1: self.minecraftJar.sha1)], progress: DownloadProgress(), callback: {})
    }
    
    public func downloadLibs(progress: DownloadProgress, callback: (() -> Void)?) -> DownloadProgress {
        var tasks: [DownloadTask] = []
        for library in libraries {
            if library.type == .local {
                continue
            }
            tasks.append(library.asDownloadTask())
        }
        return ParallelDownloader.download(tasks, progress: progress, callback: callback)
    }
    
    public func downloadAssets(progress: DownloadProgress, callback: (() -> Void)?) throws -> DownloadProgress {
        let index = try AssetIndex.get(version: self.assetIndex.id, urlStr: self.assetIndex.url)
        return try index.downloadParallel(progress: progress, callback: callback)
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

public protocol InstanceData: Codable {
}
