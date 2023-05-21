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

public class VanillaInstanceCreator: InstanceCreator {
    public let name: String
    public let versionUrl: URL
    public let sha1: String
    public let notes: String?
    public let data: LauncherData
    
    public init(name: String, versionUrl: URL, sha1: String, notes: String?, data: LauncherData) {
        self.name = name
        self.versionUrl = versionUrl
        self.sha1 = sha1
        self.notes = notes
        self.data = data
    }
    
    public func install() throws -> Instance {
        let version = try Version.download(versionUrl, sha1: self.sha1)
        let libraries: [LibraryArtifact] = version.libraries.filter({ lib in
            lib.rules?.allMatchRules(givenFeatures: [:]) ?? true
        }).map{ $0.downloads }.map { $0.artifact }
        let mcJar = MinecraftJar(type: .remote, url: version.downloads.client.url, sha1: version.downloads.client.sha1)
        let logo = InstanceLogo(logoType: .builtin, string: "icon")
        let instance: Instance = Instance(name: self.name, assetIndex: version.assetIndex, libraries: libraries, mainClass: version.mainClass, minecraftJar: mcJar, isStarred: false, logo: logo, description: self.notes, debugString: version.id, arguments: version.arguments)
        try instance.createAsNewInstance()
        logger.info("Successfully created vanilla instance \(self.name)")
        
        return instance
    }
}
