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
        var libraries: [Library] = []
        for lib in version.libraries {
            libraries.append(
                Library(type: .remote, path: lib.downloads.artifact.path, url: lib.downloads.artifact.url, sha1: lib.downloads.artifact.sha1)
            )
        }
        let mcJar = MinecraftJar(type: .remote, url: version.downloads.client.url, sha1: version.downloads.client.sha1)
        let logo = InstanceLogo(logoType: .symbol, string: "tray.circle")
        let instance: Instance = Instance(name: self.name, assetIndex: version.assetIndex, libraries: libraries, mainClass: version.mainClass, minecraftJar: mcJar, isStarred: false, logo: logo, description: self.notes, debugString: version.id, gameArguments: version.arguments.game)
        if (version.arguments.jvm.contains("-XstartOnFirstThread")) {
            instance.setStartOnFirstThread()
        }
        try instance.createAsNewInstance()
        
        return instance
    }
}
