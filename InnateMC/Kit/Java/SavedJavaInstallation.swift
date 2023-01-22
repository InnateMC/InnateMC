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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Foundation

public class SavedJavaInstallation: Codable, Identifiable {
    public static let systemDefault = SavedJavaInstallation(javaHomePath: "/usr", javaVendor: "System Default", javaVersion: "", installationType: .detected)
    public let javaHomePath: String
    public let javaVendor: String
    public let javaVersion: String
    public let installationType: InstallationType
    
    public init(javaHomePath: String, javaVendor: String, javaVersion: String, installationType: InstallationType) {
        self.javaHomePath = javaHomePath
        self.javaVendor = javaVendor
        self.javaVersion = javaVersion
        self.installationType = installationType
    }
    
    public init(linkedJavaInstallation: LinkedJavaInstallation) {
        self.javaHomePath = linkedJavaInstallation.JVMHomePath
        self.javaVendor = linkedJavaInstallation.JVMVendor
        self.javaVersion = linkedJavaInstallation.JVMVersion
        self.installationType = .detected
    }
    
    public func getString() -> String {
        if (javaVersion == "") {
            return "\(javaVendor) at \(javaHomePath)/bin/java"
        }
        return "\(javaVersion) | \(javaVendor) at \(javaHomePath)"
    }
    
    public enum InstallationType: Codable, Hashable, Equatable {
        case detected // detected from /usr/libexec/java_home
        case selected // user selected
        case downloaded // downloaded by InnateMC
    }
}

extension SavedJavaInstallation {
    public static let filePath: URL = FileHandler.javaFolder.appendingPathComponent("Saved.plist")
    public static let encoder = PropertyListEncoder()
    public static let decoder = PropertyListDecoder()
    
    public static func load() throws -> [SavedJavaInstallation] {
        let data = try FileHandler.getData(filePath)
        
        guard let data = data else {
            let saved = LinkedJavaInstallation.getAll().toSaved()
            try saved.save()
            return saved
        }
        do {
            let versions: [SavedJavaInstallation] = try decoder.decode([SavedJavaInstallation].self, from: data)
            return versions
        } catch {
            try! FileManager.default.removeItem(at: filePath)
            return []
        }
    }
}

extension SavedJavaInstallation: Hashable {
    public static func == (lhs: SavedJavaInstallation, rhs: SavedJavaInstallation) -> Bool {
        return lhs.javaHomePath == rhs.javaHomePath
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(javaHomePath)
    }
}

extension Array where Element == SavedJavaInstallation {
    func save() throws {
        SavedJavaInstallation.encoder.outputFormat = .xml
        let data = try SavedJavaInstallation.encoder.encode(self)
        try FileHandler.saveData(SavedJavaInstallation.filePath, data)
    }
}

extension Array where Element == LinkedJavaInstallation {
    func toSaved() -> [SavedJavaInstallation] {
        return self.map { SavedJavaInstallation(linkedJavaInstallation: $0) }
    }
}
