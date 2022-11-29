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
import InnateJson

public class VersionManifest {
    public static func downloadThrow() -> [ManifestVersion] {
        return try! download()
    }

    public static func download() throws -> [ManifestVersion] {
        if let url = URL(string: "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json") {
            let contents = try String(contentsOf: url)
            let json = InnateParser.readJson(contents)!
            return readFromDict(json)
        } else {
            fatalError("Not possible")
        }
    }

    public static func readFromDict(_ dict: [String: InnateValue]) -> [ManifestVersion] {
        var versions: [ManifestVersion] = []
        let versionsJsonArray = dict["versions"]!.asArray()!
        for versionJson in versionsJsonArray {
            let versionObj = versionJson.asObject()!
            versions.append(ManifestVersion(version: versionObj["id"]!.asString()!, type: versionObj["type"]!.asString()!, url: versionObj["url"]!.asString()!, time: versionObj["time"]!.asString()!, releaseTime: versionObj["releaseTime"]!.asString()!, sha1: versionObj["sha1"]!.asString()!))
        }
        return versions;
    }
}

public struct ManifestVersion: Hashable, Codable, Identifiable {
    public var version: String
    public var type: String
    public var url: String
    public var time: String
    public var releaseTime: String
    public var sha1: String
    
    public var id: Self { self }
}
