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

public class AssetIndex: Codable {
    public let version: String
    public let json: String
    public let objects: [String: [String: String]]

    init(version: String, json: String, objects: [String: [String: String]]) {
        self.version = version
        self.json = json
        self.objects = objects
    }

    public static func get(version: String, urlStr: String) throws -> AssetIndex {
        let indexes: URL = FileHandler.assetsFolder.appendingPathComponent("indexes", isDirectory: true)
        let indexesFile: URL = indexes.appendingPathComponent(version + ".json", isDirectory: false)
        if FileManager.default.fileExists(atPath: indexesFile.path) {
            return fromJson(try String(contentsOf: indexesFile), version: version)
        }
        if let url = URL(string: urlStr) {
            let contents = try String(contentsOf: url)
            return fromJson(contents, version: version)
        } else {
            fatalError("Not possible")
        }
    }

    public static func fromJson(_ jsonStr: String, version: String) -> AssetIndex {
        let json = InnateParser.readJson(jsonStr)!
        let objects = json["objects"]!.asObject()!
        let strs = objects.mapValues { $0.asObject()!.mapValues({v in return v.asString()!} ) }
        return AssetIndex(version: version, json: jsonStr, objects: strs)
    }

    public func downloadParallel(progress: DownloadProgress, callback: (() -> Void)?) throws -> DownloadProgress {
        let fm = FileManager.default
        let objects: URL = FileHandler.assetsFolder.appendingPathComponent("objects", isDirectory: true)
        let indexes: URL = FileHandler.assetsFolder.appendingPathComponent("indexes", isDirectory: true)
        if !fm.fileExists(atPath: objects.path) {
            try fm.createDirectory(at: objects, withIntermediateDirectories: true)
        }
        if !fm.fileExists(atPath: indexes.path) {
            try fm.createDirectory(at: indexes, withIntermediateDirectories: true)
        }
        let indexesFile: URL = indexes.appendingPathComponent(self.version + ".json", isDirectory: false)
        if !fm.fileExists(atPath: indexesFile.path) {
            fm.createFile(atPath: indexesFile.path, contents: self.json.data(using: .utf8))
        }
        var tasks: [DownloadTask] = []
        for (_, v) in self.objects {
            let hash = v["hash"]!
            let fromIndex = hash.index(hash.startIndex, offsetBy: 2)
            let hashPre = String(hash[..<fromIndex])
            let hashFolder = objects.appendingPathComponent(hashPre, isDirectory: true)
            let path = hashFolder.appendingPathComponent(hash, isDirectory: false)
            let url = URL(string: "https://resources.download.minecraft.net/" + hashPre + "/" + hash)!
            tasks.append(DownloadTask(url: url, filePath: path, sha1: nil))
        }
        return ParallelDownloader.download(tasks, progress: progress, callback: callback)
    }
}
