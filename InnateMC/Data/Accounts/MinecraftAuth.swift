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

struct MinecraftAuth: Codable {
    let identityToken: String
    
    init(identityToken: String) {
        self.identityToken = identityToken
    }
    
    init(fromXboxAuthResponse xboxAuthResponse: XboxAuthResponse) {
        guard let userHash = xboxAuthResponse.userHash else {
            fatalError("Invalid XSTS auth response.")
        }
        self.identityToken = "XBL3.0 x=\(userHash);\(xboxAuthResponse.token)"
    }
}
