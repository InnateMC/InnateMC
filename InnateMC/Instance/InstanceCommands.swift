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

struct InstanceCommands: Commands {
    public var launcherData: LauncherData
    @State private var instanceIsntSelected: Bool = false
    @FocusedValue(\.selectedInstance) private var selectedInstance: Instance?
    
    var body: some Commands {
        CommandMenu("Instance") {
            Button(action: {
                if let instance = selectedInstance {
                    instance.isStarred = !instance.isStarred
                }
            }) {
                if selectedInstance?.isStarred ?? false {
                    Label {
                        Text("Unstar")
                    } icon: {
                        Image(systemName: "star.slash")
                    }
                } else {
                    Label {
                        Text("Star")
                    } icon: {
                        Image(systemName: "star")
                    }
                }
            }
            .disabled(selectedInstance == nil)
            .keyboardShortcut("f")
            Button(action: {
                // TODO: implement
            }) {
                Label { Text("Launch") } icon: { Image(systemName: "paperplane") }
            }
            .keyboardShortcut(KeyEquivalent.return)
            .disabled(selectedInstance == nil)
            Button(action: {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: selectedInstance!.getPath().path)
            }) {
                Label { Text("Open in Finder") } icon: { Image(systemName: "folder") }
            }
            .keyboardShortcut(KeyEquivalent.upArrow)
            .disabled(selectedInstance == nil)
            
            Divider()
            
            Button("Open Instances Folder") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.shift, .command])
            Button("New Instance") {
                DispatchQueue.main.async {
                    launcherData.newInstanceRequested = true
                }
            }
            .keyboardShortcut("n")
        }
    }
}
