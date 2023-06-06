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

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let urk = URL(fileURLWithPath: "/Users/ShrishDeshpande/Library/Application Support/PrismLauncher/instances/Create- Above and Beyond/minecraft/logs/2022-09-01-4.log.gz")
        let app = URL(fileURLWithPath: "/System/Applications/Utilities/Console.app/Contents/MacOS/Console")
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.open([urk], withApplicationAt: app, configuration: config)
    }
    
    func applicationWillFinishLaunching(_ notification: Notification) {
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
