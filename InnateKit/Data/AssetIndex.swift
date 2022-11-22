//
//  AssetIndex.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/21/22.
//

import Foundation
import InnateJson

public class AssetIndex {
    private let version: String
    private let json: String
    private let objects: [String: InnateValue]
    
    init(version: String, json: String, objects: [String: InnateValue]) {
        self.version = version
        self.json = json
        self.objects = objects
    }
    
    public static func download(version: String, urlStr: String) throws -> AssetIndex {
        if let url = URL(string: urlStr) {
            let contents = try String(contentsOf: url)
            let json = InnateParser.readJson(contents)!
            let objects = json["objects"]!.asObject()!
            return AssetIndex(version: version, json: contents, objects: objects)
        } else {
            fatalError("Not possible")
        }
    }

    public func downloadParallel() throws -> DownloadProgress {
        let fm = FileManager.default
        let objects: URL = FolderHandler.assetsFolder.appendingPathComponent("objects", isDirectory: true)
        let indexes: URL = FolderHandler.assetsFolder.appendingPathComponent("indexes", isDirectory: true)
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
            let hash = v.asObject()!["hash"]!.asString()!
            let hashPre = String(hash.substring(to: hash.index(after: hash.index(after: hash.startIndex))))
            let hashFolder = objects.appendingPathComponent(hashPre, isDirectory: true)
            let path = hashFolder.appendingPathComponent(hash, isDirectory: false)
            let url = URL(string: "https://resources.download.minecraft.net/" + hashPre + "/" + hash)!
            tasks.append(DownloadTask(url: url, filePath: path, sha1: nil))
        }
        let progress = DownloadProgress()
        ParallelDownloader.download(tasks, progress: progress)
        return progress
    }
}
