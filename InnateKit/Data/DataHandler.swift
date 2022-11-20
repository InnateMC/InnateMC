//
//  DataHandler.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/18/22.
//

import Foundation

public class DataHandler {
    public static func getOrCreateFolder() -> URL {
        let fileManager = FileManager.default
        var documentsUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folderUrl = documentsUrl.appendingPathComponent("InnateMC")
        if !fileManager.fileExists(atPath: folderUrl.path) {
            do {
                try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(at: folderUrl.appendingPathComponent("Instances"), withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(at: folderUrl.appendingPathComponent("Libraries"), withIntermediateDirectories: true, attributes: nil)
                try fileManager.createDirectory(at: folderUrl.appendingPathComponent("Assets"), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating folder: \(error)")
            }
        }
        return folderUrl
    }

    public static func getOrCreateFolder(_ name: String) -> URL {
        let fileManager = FileManager.default
        let folderUrl = getOrCreateFolder().appendingPathComponent(name)
        if !fileManager.fileExists(atPath: folderUrl.path) {
            do {
                try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating folder: \(error)")
            }
        }
        return folderUrl
    }

    public static func loadInstances() -> [Instance] {
        let appSupportFolder = getOrCreateFolder()
        var instances: [Instance] = []
        // Walk through directories in innateMcUrl
        let directoryContents = try! FileManager.default.contentsOfDirectory(
                at: appSupportFolder,
                includingPropertiesForKeys: nil
        )
        for url in directoryContents {
            if !url.hasDirectoryPath {
                continue
            }
            if !url.lastPathComponent.hasSuffix(".innate") {
                continue
            }
            let instance = Instance.loadFromDirectory(url)
            instances.append(instance)
        }
        return instances
    }

    public static func loadPlist(_ url: URL) -> [String: Any] {
        if url.pathExtension != "plist" {
            fatalError("Not a plist file")
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            return [:]
        }
        let data = try! Data(contentsOf: url)
        let dict = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        return dict
    }

    public static func savePlist(_ url: URL, _ dict: [String: Any]) {
        let data = try! PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: data)
        } else {
            try! data.write(to: url)
        }
    }
}

#if DEBUG
extension DataHandler {
    public static func createTestInstances()  {
        let names = ["Test1", "Test2", "Test3"]
        for name in names {
            let instanceFolder = getOrCreateFolder("Instances").appendingPathComponent(name + ".innate")
            if FileManager.default.fileExists(atPath: instanceFolder.path) {
                continue
            }
            try! FileManager.default.createDirectory(at: instanceFolder, withIntermediateDirectories: true, attributes: nil)
            let instance = Instance(path: instanceFolder, name: name)
            let instancePlist = instanceFolder.appendingPathComponent("Instance.plist")
            let dict = instance.serialize()
            savePlist(instancePlist, dict)
        }
    }
}
#endif
