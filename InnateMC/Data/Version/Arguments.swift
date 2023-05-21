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

public struct Arguments: Codable, Equatable {
    public static let none: Arguments = .init(game: [], jvm: [])
    let game: [ArgumentElement]
    let jvm: [ArgumentElement]
    
    public static func +(lhs: Arguments, rhs: Arguments) -> Arguments {
        let combinedGame = lhs.game + rhs.game
        let combinedJvm = lhs.jvm + rhs.jvm
        return Arguments(game: combinedGame, jvm: combinedJvm)
    }
    
    public init(game: [ArgumentElement], jvm: [ArgumentElement]) {
        self.game = game
        self.jvm = jvm
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(game, forKey: .game)
        try container.encode(jvm, forKey: .jvm)
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            game = try container.decode([ArgumentElement].self, forKey: .game)
            jvm = try container.decode([ArgumentElement].self, forKey: .jvm)
        } else if var unkeyedContainer = try? decoder.unkeyedContainer() {
            var gameArray = [ArgumentElement]()
            while !unkeyedContainer.isAtEnd {
                if let stringValue = try? unkeyedContainer.decode(String.self) {
                    gameArray.append(ArgumentElement.string(stringValue))
                }
            }
            game = gameArray
            jvm = []
        } else {
            game = []
            jvm = []
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case game
        case jvm
    }
}
