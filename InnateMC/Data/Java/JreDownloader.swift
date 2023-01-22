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

public final class JreDownloader {
    public static func download(version: Int) throws {
        let url = URL(string: getUrl(version: version))!
        let data = try Data(contentsOf: url)
        
    }
    
    private static func getUrl(version: Int) -> String {
        return "https://api.adoptium.net/v3/binary/latest/\(version)/ga/mac/\(formattedArchitecture)/jre/hotspot/normal/eclipse"
    }
    
    private static var architecture: String {
        var sysinfo = utsname()
        let result = uname(&sysinfo)
        guard result == EXIT_SUCCESS else {
            fatalError()
        }
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        guard let identifier = String(bytes: data, encoding: .ascii) else {
            fatalError()
        }
        return identifier.trimmingCharacters(in: .controlCharacters)
    }
    
    private static var formattedArchitecture: String {
        let arch = architecture.lowercased()
        if (arch.contains("arm")) {
            return "aarch64"
        }
        return "x86_64"
    }
}

