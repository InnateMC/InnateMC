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

public class GlobalPreferences: Codable, ObservableObject {
    @Published public var runtime: RuntimePreferences = RuntimePreferences()
    @Published public var ui: UiPreferences = UiPreferences()
}

extension GlobalPreferences {
    public static let filePath = try! FileHandler.getOrCreateFolder().appendingPathComponent("Preferences.plist")
    
    public static func load() throws -> GlobalPreferences {
        if let data = try FileHandler.getData(filePath) {
            return try PropertyListDecoder().decode(GlobalPreferences.self, from: data)
        } else {
            let prefs = GlobalPreferences()
            prefs.save()
            return prefs
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
