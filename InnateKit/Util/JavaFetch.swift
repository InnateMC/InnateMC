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

public class JavaFetch {
    private static let decoder = PropertyListDecoder()
    
    public static func getAvailableJavaVersions() throws -> [JavaVersion] {
        let process = Process()
        process.launchPath = "/usr/libexec/java_home"
        process.arguments = ["-X"]
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let versions: [JavaVersion] = try decoder.decode([JavaVersion].self, from: outputData)
        return versions
    }
}

public class JavaVersion: Codable {
    public let JVMArch: String
    public let JVMBundleID: String
    public let JVMEnabled: Bool
    public let JVMHomePath: String
    public let JVMName: String
    public let JVMPlatformVersion: String
    public let JVMVendor: String
    public let JVMVersion: String
    public var javaPath: String {
        get {
            return "\(JVMHomePath)/bin/java"
        }
    }
}
