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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Foundation

extension Instance {
    public func save() throws {
        try FileHandler.saveData(self.getPath().appendingPathComponent("Instance.plist"), serialize())
    }
    
    public func serialize() throws -> Data {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return try encoder.encode(self)
    }
    
    internal static func deserialize(_ data: Data, path: URL) throws -> Instance {
        let decoder = PropertyListDecoder()
        return try decoder.decode(Instance.self, from: data)
    }
    
    public static func loadFromDirectory(_ url: URL) throws -> Instance {
        return try deserialize(FileHandler.getData(url.appendingPathComponent("Instance.plist"))!, path: url)
    }
    
    public static func loadInstances() throws -> [Instance] {
        var instances: [Instance] = []
        let directoryContents: [URL] = try FileManager.default.contentsOfDirectory(
            at: FileHandler.instancesFolder,
            includingPropertiesForKeys: nil
        )
        for url in directoryContents {
            if !url.hasDirectoryPath {
                continue
            }
            if !url.lastPathComponent.hasSuffix(".innate") {
                continue
            }
            let instance: Instance
            do {
                instance = try Instance.loadFromDirectory(url)
            } catch {
                logger.error("Error loading instance at \(url.path)", error: error)
                continue
            }
            instances.append(instance)
            logger.debug("Loaded instance \(instance.name)")
        }
        return instances
    }
    
    public static func loadInstancesThrow() -> [Instance] {
        return try! loadInstances()
    }
    
    func createAsNewInstance() throws {
        let instancePath = getPath()
        let fm = FileManager.default
        if fm.fileExists(atPath: instancePath.path) {
            logger.notice("Instance already exists at path, overwriting")
            try fm.removeItem(at: instancePath)
        }
        try fm.createDirectory(at: instancePath, withIntermediateDirectories: true)
        try FileHandler.saveData(instancePath.appendingPathComponent("Instance.plist"), serialize())
        logger.info("Successfully created new instance \(self.name)")
    }
    
    public func delete() {
        do {
            try FileManager.default.removeItem(at: getPath())
            logger.info("Successfully deleted instance \(self.name)")
        } catch {
            logger.error("Error deleting instance \(self.name)", error: error)
        }
    }
    
    public func renameAsync(to newName: String) {
        let oldName = self.name
        DispatchQueue.global(qos: .userInteractive).async {
            // TODO: handle the errors
            let original = self.getPath()
            try! FileManager.default.copyItem(at: original, to: Instance.getInstancePath(for: newName))
            DispatchQueue.main.async {
                self.name = newName
                DispatchQueue.global(qos: .userInteractive).async {
                    try! FileManager.default.removeItem(at: original)
                }
                logger.info("Successfully renamed instance \(oldName) to \(newName)")
            }
        }
    }
}
