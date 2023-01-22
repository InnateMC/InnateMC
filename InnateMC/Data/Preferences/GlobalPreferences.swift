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
    
    public class UiPreferences: Codable, ObservableObject {
        @Published public var leftAlignedInstanceHeading: Bool
        @Published public var compactList: Bool
        
        init(leftAlignedInstanceHeading: Bool, compactList: Bool) {
            self.leftAlignedInstanceHeading = leftAlignedInstanceHeading
            self.compactList = compactList
        }
        
        init() {
            self.leftAlignedInstanceHeading = true
            self.compactList = false
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
