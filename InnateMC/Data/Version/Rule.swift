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

public struct Rule: Codable, Equatable {
    let action: ActionType
    let features: [String: Bool]?
    let os: OS?
    
    public enum ActionType: String, Codable, Equatable {
        case allow
        case disallow
    }
    
    public struct OS: Codable, Equatable {
        let name: OSName?
        let version: String?
        let arch: String?
        
        public enum OSName: String, Codable, Equatable {
            case osx
            case linux
            case windows
        }
    }
    
    public func matches(givenFeatures: [String:Bool]) -> Bool {
        var ok = true
        if let os = os {
            if let name = os.name {
                ok = ok && name == .osx
            }
            // TODO: implement
        }
        if let features = features {
            for (feature, value) in features where ok == true {
                ok = ok && (givenFeatures[feature] == value)
            }
        }
        return ok
    }
}

extension Array where Element == Rule {
    func allMatchRules(givenFeatures: [String:Bool]) -> Bool {
        var ok = true
        for rule in self where ok == true {
            ok = ok && rule.matches(givenFeatures: givenFeatures)
        }
        return ok
    }
}

