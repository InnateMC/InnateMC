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

import SwiftUI

struct DeveloperModeCommands: Commands {
    @AppStorage("developerMode") var developerMode: Bool = true
    
    var body: some Commands {
        getCommands()
    }
    
    func getCommands() -> some Commands {
        if #available(macOS 13, *) {
            return getNewCommands()
        } else {
            return getOldCommands()
        }
    }
    
    @CommandsBuilder
    func getOldCommands() -> some Commands {
        CommandMenu(i18n("develop")) {
            if developerMode {
                Button(i18n("show_console")) {
                    let workspace = NSWorkspace.shared
                    let consoleURL = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app")
                    let appURL = Bundle.main.bundleURL
                    let config: NSWorkspace.OpenConfiguration = .init()
                    config.arguments = [appURL.path]
                    Task {
                        try! await workspace.openApplication(at: consoleURL, configuration: config)
                    }
                }
            }
        }
    }
    
    @available(macOS 13, *)
    @CommandsBuilder
    func getNewCommands() -> some Commands {
        if developerMode {
            CommandMenu(i18n("develop")) {
                Button(i18n("show_console")) {
                    let workspace = NSWorkspace.shared
                    let consoleURL = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app")
                    let appURL = Bundle.main.bundleURL
                    let config: NSWorkspace.OpenConfiguration = .init()
                    config.arguments = [appURL.path]
                    Task {
                        try! await workspace.openApplication(at: consoleURL, configuration: config)
                    }
                }
            }
        }
    }
}
