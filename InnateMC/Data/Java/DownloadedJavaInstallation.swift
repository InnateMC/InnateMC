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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public class DownloadedJavaInstallation: Codable, Identifiable {
    public let version: String
    public let path: String
}

extension DownloadedJavaInstallation {
    public static let filePath: URL = FileHandler.javaFolder.appendingPathComponent("Index.plist")
    public static let encoder = PropertyListEncoder()
    public static let decoder = PropertyListDecoder()
    
    public static func load() throws -> [DownloadedJavaInstallation] {
        let data = try FileHandler.getData(filePath)
        
        guard let data = data else {
            return []
        }
        do {
            let versions: [DownloadedJavaInstallation] = try decoder.decode([DownloadedJavaInstallation].self, from: data)
            return versions
        } catch {
            try! FileManager.default.removeItem(at: FileHandler.javaFolder)
            try! FileManager.default.createDirectory(at: FileHandler.javaFolder, withIntermediateDirectories: true)
            return []
        }
    }
}

extension Array where Element == DownloadedJavaInstallation {
    func save() throws {
        DownloadedJavaInstallation.encoder.outputFormat = .xml
        let data = try DownloadedJavaInstallation.encoder.encode(self)
        try FileHandler.saveData(DownloadedJavaInstallation.filePath, data)
    }
}
