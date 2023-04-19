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

open class MinecraftAccount: Codable, Identifiable {
    public var id: UUID {
        return getUUID()
    }
    
    public var strType: String {
        return getType().rawValue
    }
    
    public var username: String {
        return getUsername()
    }
    
    func getType() -> MinecraftAccountType {
        fatalError("Must be implemented by subclasses")
    }
    
    func getUsername() -> String {
        fatalError("Must be implemented by subclasses")
    }
    
    func getUUID() -> UUID {
        fatalError("Must be implemented by subclasses")
    }
    
    static func createFromDict(_ dict: [String:Any]) -> Self {
        let data = try! PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        let decoded = try! minecraftAccountDecoder.decode(Self.self, from: data)
        return decoded
    }
}


internal let minecraftAccountDecoder = PropertyListDecoder()

enum MinecraftAccountType: String, Codable {
    case microsoft = "Microsoft"
    case offline = "Offline"
}
