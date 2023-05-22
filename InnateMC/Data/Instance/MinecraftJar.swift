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

public struct MinecraftJar: Codable {
    public var type: FileType
    public var url: URL?
    public var sha1: String?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case url
        case sha1
    }
    
    public init(type: FileType, url: URL?, sha1: String?) {
        self.type = type
        self.url = url
        self.sha1 = sha1
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try container.decode(FileType.self, forKey: .type)
        sha1 = try container.decodeIfPresent(String.self, forKey: .sha1)
        
        if let urlString = try container.decodeIfPresent(String.self, forKey: .url) {
            url = URL(string: urlString)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(sha1, forKey: .sha1)
        
        if let url = url {
            try container.encode(url.absoluteString, forKey: .url)
        }
    }
}
