//
// Copyright © 2022 Shrish Deshpande
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
// along with this program.  If not, see <http://www.gnu.org/licenses/>
//

import Foundation

public class RuntimePreferences: Codable, ObservableObject {
    @Published public var defaultJava: SavedJavaInstallation
    @Published public var minMemory: Int
    @Published public var maxMemory: Int
    @Published public var javaArgs: String
    
    public init(minMemory: Int, maxMemory: Int, javaArgs: String, defaultJava: SavedJavaInstallation) {
        self.minMemory = minMemory
        self.maxMemory = maxMemory
        self.javaArgs = javaArgs
        self.defaultJava = defaultJava
    }
    
    public init() { // Fallback provider
        self.minMemory = 1024
        self.maxMemory = 1024
        self.javaArgs = ""
        self.defaultJava = SavedJavaInstallation.systemDefault
    }
}

public class OptRuntimePreferences: Codable, ObservableObject {
    @Published public var defaultJava: SavedJavaInstallation? = nil
    @Published public var minMemory: Int? = nil
    @Published public var maxMemory: Int? = nil
    @Published public var javaArgs: String? = nil
}
