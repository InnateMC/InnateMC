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
import SwiftUI

class OfflineAccount: MinecraftAccount {
    private static let decoder = JSONDecoder()
    var type: MinecraftAccountType = .offline
    var uname: String
    var uuid: UUID
    
    init(username: String, uuid: UUID) {
        self.uname = username
        self.uuid = uuid
        super.init()
    }
    
    public static func createFromUsername(_ username: String) -> OfflineAccount {
        return OfflineAccount(username: username, uuid: UUID())
    }
    
    override func getType() -> MinecraftAccountType {
        return .offline
    }
    
    override func getUsername() -> String {
        return self.uname
    }
    
    override func getUUID() -> UUID {
        return uuid
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(MinecraftAccountType.self, forKey: .type)
        self.uname = try container.decode(String.self, forKey: .username)
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(username, forKey: .username)
        try container.encode(uuid, forKey: .uuid)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case username
        case uuid
    }
}
