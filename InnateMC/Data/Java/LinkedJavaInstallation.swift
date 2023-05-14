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

public class LinkedJavaInstallation: Codable {
    public let JVMArch: String
    public let JVMBundleID: String
    public let JVMEnabled: Bool
    public let JVMHomePath: String
    public let JVMName: String
    public let JVMPlatformVersion: String
    public let JVMVendor: String
    public let JVMVersion: String
}

extension LinkedJavaInstallation {
    private static let decoder: PropertyListDecoder = PropertyListDecoder()
    
    public static func getAll() throws -> [LinkedJavaInstallation] {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/libexec/java_home")
        p.arguments = ["-X"]
        let pipe = Pipe()
        p.standardOutput = pipe
        p.launch()
        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
        let installations = try decoder.decode([LinkedJavaInstallation].self, from: data)
        return installations
    }
}
