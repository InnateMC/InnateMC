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

struct ErrorTrackerEntry: Hashable, Equatable {
    var type: TrackedErrorType
    var description: String
    var error: Error?
    var timestamp: Double
    var counter: Int
    static var counterGlobal: Int = 0
    
    init(type: TrackedErrorType, description: String, error: Error?, timestamp: Double) {
        self.type = type
        self.description = description
        self.error = error
        self.timestamp = timestamp
        Self.counterGlobal += 1
        self.counter = Self.counterGlobal
    }
    
    init(type: TrackedErrorType, description: String, timestamp: Double) {
        self.init(type: type, description: description, error: nil, timestamp: timestamp)
    }
    
    static func == (lhs: ErrorTrackerEntry, rhs: ErrorTrackerEntry) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }
}
