//
//  DataHandler.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/18/22.
//

import Foundation

public class FolderHandler {
    public static let instancesFolder = try! getOrCreateFolder("Instances")
    public static let assetsFolder = try! getOrCreateFolder("Assets")
    public static let librariesFolder = try! getOrCreateFolder("Libraries")
    
    public static func getOrCreateFolder() throws -> URL {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderUrl = documentsUrl.appendingPathComponent("InnateMC")
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: folderUrl.appendingPathComponent("Instances"), withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: folderUrl.appendingPathComponent("Libraries"), withIntermediateDirectories: true, attributes: nil)
            try fileManager.createDirectory(at: folderUrl.appendingPathComponent("Assets"), withIntermediateDirectories: true, attributes: nil)
        }
        return folderUrl
    }

    public static func getOrCreateFolder(_ name: String) throws -> URL {
        let fileManager = FileManager.default
        let folderUrl = try getOrCreateFolder().appendingPathComponent(name)
        if !fileManager.fileExists(atPath: folderUrl.path) {
            try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
        return folderUrl
    }
    
    public static func getData(_ url: URL) throws -> Data? {
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        return try Data(contentsOf: url)
    }

    public static func saveData(_ url: URL, _ data: Data) throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: data)
        } else {
            try data.write(to: url)
        }
    }
}
