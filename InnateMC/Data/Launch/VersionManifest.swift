//
// Copyright © 2022 InnateMC and contributors
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

public class VersionManifest {
    private static let cache: URL = try! FileHandler.getOrCreateFolder().appendingPathComponent("ManifestCache.plist")
    private static var cached: [PartialVersion]? = nil
    private static let decoder = JSONDecoder()
    
    public static func getOrCreate() async throws -> [PartialVersion] {
        if cached == nil {
            cached = try await download()
        }
        return cached!
    }
    
    public static func download() async throws -> [PartialVersion] {
        guard let url = URL(string: "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json") else {
            fatalError("Not possible")
        }
        
        let data: Data
        
        do {
            data = try await URLSession.shared.data(from: url).0
        } catch {
            logger.error("Could not download version manifest", error: error)
            ErrorTracker.instance.error(error: error, description: "Could not download version manifest")
            logger.error("Trying to load cached version manifest")
            let parsed = try fetchCache()
            return parsed
        }
        let parsed = try readFromData(data)
        Task {
            try FileHandler.saveData(cache, PropertyListEncoder().encode(parsed))
        }
        return parsed
    }
    
    public static func fetchCache() throws -> [PartialVersion] {
        guard let data = try FileHandler.getData(cache) else {
            logger.error("Did not find cached version manifest")
            throw VersionManifestError.noCacheFound
        }
        return try PropertyListDecoder().decode([PartialVersion].self, from: data)
    }
    
    public static func readFromData(_ data: Data) throws -> [PartialVersion] {
        let root = try decoder.decode(RootJSON.self, from: data)
        return root.versions
    }
    
    public enum VersionManifestError: Error {
        case noCacheFound
        
        var localizedDescription: String {
            switch(self) {
            case .noCacheFound:
                return "Missing version manifest cache and could not download from version manifest"
            }
        }
    }
}

internal struct RootJSON: Codable {
    let versions: [PartialVersion]
}

public struct PartialVersion: Codable, Hashable, Identifiable {
    public var id: Self { self }
    
    public var version: String
    public var type: String
    public var url: String
    public var time: String
    public var releaseTime: String
    public var sha1: String
    public var complianceLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case version = "id"
        case type
        case url
        case time
        case releaseTime
        case sha1
        case complianceLevel
    }
    
    public static func createBlank() -> PartialVersion {
        return PartialVersion(id: "no", version: "no", type: "no", url: "no", time: "no", releaseTime: "no", sha1: "no", complianceLevel: 0)
    }
    
    public init(id: String, version: String, type: String, url: String, time: String, releaseTime: String, sha1: String, complianceLevel: Int) {
        self.version = version
        self.type = type
        self.url = url
        self.time = time
        self.releaseTime = releaseTime
        self.sha1 = sha1
        self.complianceLevel = complianceLevel
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(String.self, forKey: .version)
        type = try container.decode(String.self, forKey: .type)
        url = try container.decode(String.self, forKey: .url)
        time = try container.decode(String.self, forKey: .time)
        releaseTime = try container.decode(String.self, forKey: .releaseTime)
        sha1 = try container.decode(String.self, forKey: .sha1)
        complianceLevel = try container.decode(Int.self, forKey: .complianceLevel)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(type, forKey: .type)
        try container.encode(url, forKey: .url)
        try container.encode(time, forKey: .time)
        try container.encode(releaseTime, forKey: .releaseTime)
        try container.encode(sha1, forKey: .sha1)
        try container.encode(complianceLevel, forKey: .complianceLevel)
    }
}
