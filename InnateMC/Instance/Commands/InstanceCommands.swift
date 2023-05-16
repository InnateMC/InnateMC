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
import SwiftUI
import Combine

struct InstanceCommands: Commands {
    var body: some Commands {
        CommandMenu(i18n("instance")) {
            if #available(macOS 13, *) {
                InstanceSpecificCommands()
            }
            
            Button(i18n("open_instances_folder")) {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.shift, .command])
            Button(i18n("new_instance")) {
                DispatchQueue.main.async {
                    LauncherData.instance.newInstanceRequested = true
                }
            }
            .keyboardShortcut("n")
        }
    }
}
