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

struct RootJSON: Codable {
    let versions: [PartialVersion]
}
