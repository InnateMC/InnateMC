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

public class SavedJavaInstallation: Codable, Identifiable, ObservableObject {
    public static let systemDefault = SavedJavaInstallation(javaHomePath: "/usr", javaVendor: "System Default", javaVersion: "")
    public var id: SavedJavaInstallation {
        return self
    }
    @Published public var javaExecutable: String
    @Published public var javaVendor: String?
    @Published public var javaVersion: String?
    public let installationType: InstallationType
    
    public init(javaHomePath: String, javaVendor: String? = nil, javaVersion: String? = nil) {
        self.javaExecutable = "\(javaHomePath)/bin/java"
        self.javaVendor = javaVendor
        self.javaVersion = javaVersion
        self.installationType = .detected
    }
    
    public init(javaExecutable: String) {
        self.javaExecutable = javaExecutable
        self.javaVendor = nil
        self.javaVersion = nil
        self.installationType = .selected
    }
    
    public init(linkedJavaInstallation: LinkedJavaInstallation) {
        self.javaExecutable = "\(linkedJavaInstallation.JVMHomePath)/bin/java"
        self.javaVendor = linkedJavaInstallation.JVMVendor
        self.javaVersion = linkedJavaInstallation.JVMVersion
        self.installationType = .detected
    }
    
    public func setVersionAsync() {
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 4) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: self.javaExecutable)
            print(process.executableURL!.path)
            print(self.javaExecutable)
            process.arguments = ["--version"]
            let pipe = Pipe()
            process.standardOutput = pipe
            try! process.run()
//            let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
//            let string = String(data: data, encoding: .utf8) ?? "no u"
//            print(string)
        }
    }
    
    public func getString() -> String {
        guard let javaVersion = javaVersion else {
            guard let javaVendor = javaVendor else {
                return javaExecutable
            }
            return "\(javaVendor) at \(javaExecutable)"
        }

        guard let javaVendor = javaVendor else {
            return "\(javaVersion) | \(javaExecutable)"
        }

        return "\(javaVersion) | \(javaVendor) at \(javaExecutable)"
    }
    
    public func getDebugString() -> String { // TODO: computed property? allows using a keypath in Table
        if let javaVersion = javaVersion {
            if let javaVendor = javaVendor {
                return "\(javaVendor) \(javaVersion)"
            } else {
                return javaVersion
            }
        } else {
            if let javaVendor = javaVendor {
                return javaVendor
            } else {
                return "Unknown"
            }
        }
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
        let data = try? FileHandler.getData(filePath)
        
        guard let data = data else {
            let saved = try LinkedJavaInstallation.getAll().toSaved()
            try saved.save()
            return saved
        }
        do {
            let versions: [SavedJavaInstallation] = try decoder.decode([SavedJavaInstallation].self, from: data)
            return versions
        } catch {
            try FileManager.default.removeItem(at: filePath)
            return []
        }
    }
}

extension SavedJavaInstallation: Hashable {
    public static func == (lhs: SavedJavaInstallation, rhs: SavedJavaInstallation) -> Bool {
        return lhs.javaExecutable == rhs.javaExecutable
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(javaExecutable)
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
