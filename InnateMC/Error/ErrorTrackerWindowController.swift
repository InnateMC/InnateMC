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

import Cocoa
import SwiftUI

class ErrorTrackerWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered, defer: false)
        window.contentView = NSHostingView(rootView: ErrorTrackerView(errorTracker: ErrorTracker.instance))
        window.title = NSLocalizedString("errors", comment: "Errors")
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
}
