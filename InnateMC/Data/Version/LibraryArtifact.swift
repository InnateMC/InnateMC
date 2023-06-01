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

public struct LibraryArtifact: Codable, Equatable {
    public let path: String
    public let url: URL
    public let sha1: String?
    public let size: Int?
    
    public init(path: String, url: URL, sha1: String?, size: Int?) {
        self.path = path
        self.url = url
        self.sha1 = sha1
        self.size = size
    }
    
    private enum CodingKeys: String, CodingKey {
        case path
        case url
        case sha1
        case size
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        path = try container.decode(String.self, forKey: .path)
        sha1 = try container.decodeIfPresent(String.self, forKey: .sha1)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url),
           let url = URL(string: urlString) {
            self.url = url
        } else {
            throw DecodingError.dataCorruptedError(forKey: .url, in: container, debugDescription: "Invalid URL string")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(url.absoluteString, forKey: .url)
        try container.encodeIfPresent(sha1, forKey: .sha1)
        try container.encodeIfPresent(size, forKey: .size)
    }
    
    public func getAbsolutePath() -> URL {
        return FileHandler.librariesFolder.appendingPathComponent(self.path, isDirectory: false)
    }
    
    public func asDownloadTask() -> DownloadTask {
        return DownloadTask(sourceUrl: url, filePath: self.getAbsolutePath(), sha1: self.sha1) // TODO: fix sha1 checking for libraries
    }
}
