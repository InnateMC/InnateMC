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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
import InnateKit

class ArgumentTests: XCTestCase {
    func test() throws {
        let toReplace = "${auth_player_name} ${auth_session} --gameDir ${game_directory} --assetsDir ${game_assets}"
        let argumentProvider = ArgumentProvider()
        argumentProvider.username("Test")
        argumentProvider.accessToken("12345")
        argumentProvider.gameDir(URL(string: "/usr/local/Cellar")!)
        argumentProvider.assetsDir(URL(string: "/opt/homebrew")!)
        let replaced = argumentProvider.accept(toReplace)
        XCTAssertEqual(replaced, "Test 12345 --gameDir /usr/local/Cellar --assetsDir /opt/homebrew")
    }
}
