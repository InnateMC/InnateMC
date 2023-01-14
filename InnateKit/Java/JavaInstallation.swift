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

public class JavaInstallation: Codable, Identifiable {
    public let version: String
    public let path: String
}

extension JavaInstallation {
    public static let filePath: URL = FileHandler.javaFolder.appendingPathComponent("Index.plist")
    public static let encoder = PropertyListEncoder()
    public static let decoder = PropertyListDecoder()
    
    public static func load() throws -> [JavaInstallation] {
        let data = try FileHandler.getData(filePath)
        
        guard let data = data else {
            return []
        }
        do {
            let versions: [JavaInstallation] = try decoder.decode([JavaInstallation].self, from: data)
            return versions
        } catch {
            try! FileManager.default.removeItem(at: FileHandler.javaFolder)
            try! FileManager.default.createDirectory(at: FileHandler.javaFolder, withIntermediateDirectories: true)
            return []
        }
    }
}

extension Array where Element == JavaInstallation {
    func save() throws {
        JavaInstallation.encoder.outputFormat = .xml
        let data = try JavaInstallation.encoder.encode(self)
        try FileHandler.saveData(JavaInstallation.filePath, data)
    }
}
