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
import SwiftUI
import InnateKit

struct InstanceListCommands: Commands {
    @FocusedBinding(\.selectedInstance) var selectedInstance
    
    var body: some Commands {
        SidebarCommands()
        CommandMenu("Instance") {
            Button(action: {
                // TODO: implement
            }) {
                Label { Text("Unstar") } icon: { Image(systemName: "star.slash") }
            }
            .disabled(true)
            .keyboardShortcut("f")
            Button(action: {
                // TODO: implement
            }) {
                Label { Text("Launch") } icon: { Image(systemName: "paperplane") }
            }
            .keyboardShortcut(KeyEquivalent.return)
            .disabled(true)
            Button(action: {
                // TODO: implement
            }) {
                Label { Text("Open in Finder") } icon: { Image(systemName: "folder") }
            }
            .keyboardShortcut(KeyEquivalent.upArrow)
            .disabled(true)
            
            Divider()
            
            Button("Open Instances Folder") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.shift, .command])
        }
    }
}
