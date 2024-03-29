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

public class SavedJavaInstallation: Codable, Identifiable, ObservableObject {
    public static let systemDefault = SavedJavaInstallation(javaHomePath: "/usr", javaVendor: "System Default", javaVersion: "")
    private static let regex = try! NSRegularExpression(pattern: "\"([^\"]+)\"", options: [])
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
    
    public func setupAsNewVersion(launcherData: LauncherData) {
        DispatchQueue.global(qos: .utility).async {
            let process = Process()
            let pipe = Pipe()
            process.executableURL = URL(fileURLWithPath: self.javaExecutable)
            process.arguments = ["-XshowSettings:properties", "-version"]
            process.standardOutput = pipe
            process.standardError = pipe
            process.launch()
            process.waitUntilExit()
            let data: Data = pipe.fileHandleForReading.availableData
            let string = String(data: data, encoding: .utf8) ?? "NO U"
            
            if let vendor = self.extractProperty(from: string, key: "java.vendor"),
               let version = self.extractProperty(from: string, key: "java.version") {
                self.javaVendor = vendor
                self.javaVersion = version
            } else {
                logger.warning("Unable to extract properties from selected java runtime")
                logger.warning("Use Java 7 or above to suppress this warning")
            }
            
            DispatchQueue.main.async {
                launcherData.javaInstallations.append(self)
            }
            
            DispatchQueue.global(qos: .utility).async {
                do {
                    try launcherData.javaInstallations.save()
                } catch {
                    logger.error("Could not save java runtime index", error: error)
                }
            }
        }
    }
    
    private func extractProperty(from output: String, key: String) -> String? {
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            if line.contains(key) {
                let components = line.components(separatedBy: "=")
                if components.count == 2 {
                    return components[1].trimmingCharacters(in: .whitespaces)
                }
            }
        }
        return nil
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
