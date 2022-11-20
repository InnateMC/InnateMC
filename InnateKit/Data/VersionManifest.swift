//
// Created by Shrish Deshpande on 11/18/22.
//

import Foundation
import InnateJson

public class VersionManifest {
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
            versions.append(ManifestVersion(id: versionObj["id"]!.asString()!, type: versionObj["type"]!.asString()!, url: versionObj["url"]!.asString()!, time: versionObj["time"]!.asString()!, releaseTime: versionObj["releaseTime"]!.asString()!, sha1: versionObj["sha1"]!.asString()!))
        }
        return versions;
    }
}

public struct ManifestVersion {
    public var id: String
    public var type: String
    public var url: String
    public var time: String
    public var releaseTime: String
    public var sha1: String
}
