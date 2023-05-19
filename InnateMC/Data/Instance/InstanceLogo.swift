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

public class InstanceLogo: Codable, InstanceData {
    public var logoType: LogoType
    public var string: String
    
    public init(logoType: LogoType, string: String) {
        self.logoType = logoType
        self.string = string
    }
    
    public enum LogoType: Codable {
        case symbol
        case file
        case builtin
    }
}
