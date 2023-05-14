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
import SwiftUI

protocol MinecraftAccount: Codable, Hashable {
    var id: UUID { get }
    
    var type: MinecraftAccountType { get }
    
    var username: String { get }
    
    static func createFromDict(_ dict: [String:Any]) -> Self
}

fileprivate let minecraftAccountDecoder = PropertyListDecoder()

extension MinecraftAccount {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id && lhs.username == rhs.username
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.username)
    }

    static func createFromDict(_ dict: [String:Any]) -> Self {
        let data = try! PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)
        let decoded = try! minecraftAccountDecoder.decode(Self.self, from: data)
        return decoded
    }
}
