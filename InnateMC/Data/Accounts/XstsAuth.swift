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
// along with this program.  If not, see http://www.gnu.org/licenses/
//

import Foundation

struct XstsAuth: Codable {
    let properties: Properties
    let relyingParty: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case properties = "Properties"
        case relyingParty = "RelyingParty"
        case tokenType = "TokenType"
    }
    
    struct Properties: Codable {
        let sandboxId: String
        let userTokens: [String]

        enum CodingKeys: String, CodingKey {
            case sandboxId = "SandboxId"
            case userTokens = "UserTokens"
        }
    }
}

extension XstsAuth {
    static func fromXblToken(_ token: String) -> Self {
        let properties = Properties(sandboxId: "RETAIL", userTokens: [token])
        return Self(properties: properties, relyingParty: "rp://api.minecraftservices.com/", tokenType: "JWT")
    }
}
