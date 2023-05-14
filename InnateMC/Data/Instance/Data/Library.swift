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

public class Library: Codable, Identifiable, InstanceData {
    public let type: FileType
    public let path: String
    public let url: String?
    public let sha1: String?
    
    public init(type: FileType, path: String, url: String?, sha1: String?) {
        self.type = type
        self.path = path
        self.url = url
        self.sha1 = sha1
    }
    
    public func getAbsolutePath() -> URL {
        return FileHandler.librariesFolder.appendingPathComponent(self.path, isDirectory: false)
    }
    
    public func asDownloadTask() -> DownloadTask {
        return DownloadTask(sourceUrl: URL(string: url!)!, filePath: self.getAbsolutePath(), sha1: self.sha1) // TODO: fix sha1 checking for libraries
    }
}
