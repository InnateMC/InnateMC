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

struct XboxLiveAuth: Codable {
    var RelyingParty: String
    var TokenType: String
    var Properties: XboxLiveAuthProperties
    
    struct XboxLiveAuthProperties: Codable {
        var AuthMethod: String
        var SiteName: String
        var RpsTicket: String
    }
    
    public static func fromToken(_ token: String) -> XboxLiveAuth {
        return XboxLiveAuth(
            RelyingParty: "http://auth.xboxlive.com",
            TokenType: "JWT",
            Properties: XboxLiveAuthProperties(
                AuthMethod: "RPS",
                SiteName: "user.auth.xboxlive.com",
                RpsTicket: "d=\(token)"
            )
        )
    }
}
