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

public class AssetIndex: Codable {
    private static let indexesDir: URL = FileHandler.assetsFolder.appendingPathComponent("indexes", isDirectory: true)
    private static let objectsDir: URL = FileHandler.assetsFolder.appendingPathComponent("objects", isDirectory: true)
    public let version: String
    public let jsonData: Data
    public let objects: [String: [String: String]]
    
    init(version: String, jsonData: Data, objects: [String: [String: String]]) {
        self.version = version
        self.jsonData = jsonData
        self.objects = objects
    }
    
    public static func get(version: String, urlStr: String) throws -> AssetIndex {
        let indexesFile: URL = AssetIndex.indexesDir.appendingPathComponent(version + ".json", isDirectory: false)
        if FileManager.default.fileExists(atPath: indexesFile.path) {
            return try fromJson(try Data(contentsOf: indexesFile), version: version)
        }
        if let url = URL(string: urlStr) {
            let contents = try Data(contentsOf: url)
            return try fromJson(contents, version: version)
        } else {
            fatalError("Not possible")
        }
    }
    
    public static func fromJson(_ jsonData: Data, version: String) throws -> AssetIndex {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any]
        let objects = jsonObject["objects"] as! [String:Any]
        let strs = objects.mapValues {
            ($0 as! [String:Any]).mapValues { v -> String in
                if let stringValue = v as? String {
                    return stringValue
                } else if let numberValue = v as? NSNumber {
                    return numberValue.stringValue
                }
                print(v)
                fatalError()
            }
        }
        return AssetIndex(version: version, jsonData: jsonData, objects: strs)
    }
    
    public func createDirectories() throws {
        let fm = FileManager.default
        let objects: URL = FileHandler.assetsFolder.appendingPathComponent("objects", isDirectory: true)
        if !fm.fileExists(atPath: AssetIndex.objectsDir.path) {
            // TODO: handle the error
            try fm.createDirectory(at: objects, withIntermediateDirectories: true)
        }
        if !fm.fileExists(atPath: AssetIndex.indexesDir.path) {
            try fm.createDirectory(at: AssetIndex.indexesDir, withIntermediateDirectories: true)
        }
        let indexFile: URL = AssetIndex.indexesDir.appendingPathComponent(self.version + ".json", isDirectory: false)
        if !fm.fileExists(atPath: indexFile.path) {
            fm.createFile(atPath: indexFile.path, contents: self.jsonData)
        }
    }
    
    public func getAssetsAsTasks() -> [DownloadTask] {
        var tasks: [DownloadTask] = []
        for (_, v) in self.objects {
            let hash = v["hash"]!
            let fromIndex = hash.index(hash.startIndex, offsetBy: 2)
            let hashPre = String(hash[..<fromIndex])
            let hashFolder = AssetIndex.objectsDir.appendingPathComponent(hashPre, isDirectory: true)
            let path = hashFolder.appendingPathComponent(hash, isDirectory: false)
            let url = URL(string: "https://resources.download.minecraft.net/" + hashPre + "/" + hash)!
            tasks.append(DownloadTask(sourceUrl: url, filePath: path, sha1: hash))
        }
        return tasks;
    }
    
    public func downloadParallel(progress: TaskProgress, callback: (() -> Void)?) throws {
        try createDirectories()
        let tasks = getAssetsAsTasks()
        ParallelExecutor.download(tasks, progress: progress, callback: callback)
    }
    
    public func downloadParallel(progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (ParallelDownloadError) -> Void) -> URLSession? {
        do {
            try createDirectories()
        } catch {
            onError(ParallelDownloadError.downloadFailed(errorKey: "error_creating_file"))
            return nil
        }
        let tasks = getAssetsAsTasks()
        return ParallelDownloader.download(tasks, progress: progress, onFinish: onFinish, onError: onError)
    }
}
