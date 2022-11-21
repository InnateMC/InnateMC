//
//  PlistHandler.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/21/22.
//

import Foundation

public class FileHandler {
    public static func getData(_ url: URL) throws -> Data {
        if !FileManager.default.fileExists(atPath: url.path) {
            return Data()
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
