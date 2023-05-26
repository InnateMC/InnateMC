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
// along with this program.  If not, see http://www.gnu.org/licenses/
//

import Foundation

public struct Mod: Identifiable, Hashable {
    public var id: Mod { self }
    var enabled: Bool
    var path: URL
    var meta: Mod.Metadata
    
    public static func == (lhs: Mod, rhs: Mod) -> Bool {
        return lhs.path == rhs.path && lhs.enabled == rhs.enabled
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(enabled)
        hasher.combine(path)
        hasher.combine(meta.name)
    }
    
    struct Metadata {
        let name: String
        let description: String
    }
    
    public static func isValidMod(url: URL) -> Bool {
        switch url.pathExtension.lowercased() {
        case "bak", "jar", "zip", "litemod":
            return true
        default:
            return false
        }
    }
    
    public static func isEnabled(url: URL) -> Bool {
        return url.pathExtension.lowercased() != "bak"
    }
    
    public static func from(url: URL) throws -> Mod {
        return Mod(enabled: isEnabled(url: url), path: url, meta: Metadata(name: "no u", description: "testing"))
    }
}

extension Array where Element == URL {
    func deserializeToMods() -> [Mod] {
        return self.filter(Mod.isValidMod).compactMap { try? Mod.from(url: $0) }
    }
}
