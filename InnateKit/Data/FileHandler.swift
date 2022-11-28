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

public class FileHandler {
    public static let instancesFolder = try! getOrCreateFolder("Instances")
    public static let assetsFolder = try! getOrCreateFolder("Assets")
    public static let librariesFolder = try! getOrCreateFolder("Libraries")
    public static let logosFolder = try! getOrCreateFolder("Logos")

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
