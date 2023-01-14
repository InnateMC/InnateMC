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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Foundation
import InnateKit

public class GlobalPreferences: Codable, ObservableObject {
    @Published public var runtime: RuntimePreferences
    @Published public var ui: UiPreferences
    
    init(runtime: RuntimePreferences, ui: UiPreferences) {
        self.runtime = runtime
        self.ui = ui
    }
    
    init() {
        self.runtime = RuntimePreferences()
        self.ui = UiPreferences()
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GlobalPreferences.CodingKeys.self)
        self.runtime = try container.decode(RuntimePreferences.self, forKey: .runtime)
        self.ui = try container.decode(UiPreferences.self, forKey: .ui)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GlobalPreferences.CodingKeys.self)
        try container.encode(runtime, forKey: .runtime)
        try container.encode(ui, forKey: .ui)
    }
    
    private enum CodingKeys: CodingKey {
        case runtime, ui
    }
    
    public class RuntimePreferences: Codable, ObservableObject {
        @Published public var minMemory: Int
        @Published public var maxMemory: Int
        @Published public var javaArgs: String
        
        init(minMemory: Int, maxMemory: Int, javaArgs: String) {
            self.minMemory = minMemory
            self.maxMemory = maxMemory
            self.javaArgs = javaArgs
        }
        
        init() { // Fallback provider
            self.minMemory = 1024
            self.maxMemory = 1024
            self.javaArgs = ""
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: RuntimePreferences.CodingKeys.self)
            self.minMemory = try container.decode(Int.self, forKey: .minMemory)
            self.maxMemory = try container.decode(Int.self, forKey: .maxMemory)
            self.javaArgs = try container.decode(String.self, forKey: .javaArgs)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: RuntimePreferences.CodingKeys.self)
            try container.encode(minMemory, forKey: .minMemory)
            try container.encode(maxMemory, forKey: .maxMemory)
            try container.encode(javaArgs, forKey: .javaArgs)
        }
        
        private enum CodingKeys: CodingKey {
            case minMemory, maxMemory, javaArgs
        }
    }
    
    public class UiPreferences: Codable, ObservableObject {
        @Published public var rightAlignedInstanceHeading: Bool
        @Published public var compactList: Bool
        
        init(rightAlignedInstanceHeading: Bool, compactList: Bool) {
            self.rightAlignedInstanceHeading = rightAlignedInstanceHeading
            self.compactList = compactList
        }
        
        init() {
            self.rightAlignedInstanceHeading = false
            self.compactList = false
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: UiPreferences.CodingKeys.self)
            self.rightAlignedInstanceHeading = try container.decode(Bool.self, forKey: .rightAlignedInstanceHeading)
            self.compactList = try container.decode(Bool.self, forKey: .compactList)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: UiPreferences.CodingKeys.self)
            try container.encode(rightAlignedInstanceHeading, forKey: .rightAlignedInstanceHeading)
            try container.encode(compactList, forKey: .compactList)
        }
        
        private enum CodingKeys: CodingKey {
            case rightAlignedInstanceHeading, compactList
        }
    }
}

extension GlobalPreferences {
    public static let filePath = try! FileHandler.getOrCreateFolder().appendingPathComponent("Preferences.plist")
    
    public static func load() -> GlobalPreferences {
        do {
            let data = try FileHandler.getData(filePath)
            if let data = data {
                return try PropertyListDecoder().decode(GlobalPreferences.self, from: data)
            } else {
                return GlobalPreferences()
            }
        } catch {
            return GlobalPreferences() // fallback
        }
    }
    
    public func save() {
        let encoder: PropertyListEncoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(self)
            try FileHandler.saveData(GlobalPreferences.filePath, data)
        } catch {
            print("Error serializing config: \(error.localizedDescription)")
            // TODO: warn
            // no-op
        }
    }
}
