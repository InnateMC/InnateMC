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

public struct ConditionalArgument: Codable, Equatable {
    let rules: [Rule]
    let value: [String]
    
    enum CodingKeys: String, CodingKey {
        case rules
        case value
    }
    
    public init(rules: [Rule], value: [String]) {
        self.rules = rules
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rules = try container.decode([Rule].self, forKey: .rules)
        
        if let singleValue = try? container.decode(String.self, forKey: .value) {
            value = [singleValue]
        } else {
            value = try container.decode([String].self, forKey: .value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rules, forKey: .rules)
        try container.encode(value, forKey: .value)
    }
}
