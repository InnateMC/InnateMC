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

enum MicrosoftAuthError: Error {
    case noError
    case microsoftCouldNotConnect
    case microsoftInvalidResponse
    case xboxCouldNotConnect
    case xboxInvalidResponse
    case xstsCouldNotConnect
    case xstsInvalidResponse
    case minecraftCouldNotConnect
    case minecraftInvalidResponse
    
    var localizedDescription: String {
        switch (self) {
        case .noError:
            return "No error!"
        case .microsoftCouldNotConnect:
            return "Could not connect to Microsoft authentication server"
        case .microsoftInvalidResponse:
            return "Invalid response received from Microsoft authentication server"
        case .xboxCouldNotConnect:
            return "Could not connect to Xbox Live authentication server"
        case .xboxInvalidResponse:
            return "Invalid response received from Xbox Live authentication server"
        case .xstsCouldNotConnect:
            return "Could not connect to Xbox XSTS authentication server"
        case .xstsInvalidResponse:
            return "Invalid response received from Xbox XSTS authentication server"
        case .minecraftCouldNotConnect:
            return "Could not connect to Minecraft authentication server"
        case .minecraftInvalidResponse:
            return "Invalid response received from Minecraft authentication server"
        }
    }
}
