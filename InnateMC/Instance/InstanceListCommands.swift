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

struct InstanceListCommands: Commands {
    public var viewModel: ViewModel
    @State private var instanceIsntSelected: Bool = false
    
    var body: some Commands {
        SidebarCommands()
        CommandMenu("Instance") {
            Button(action: {
                if let instance = viewModel.selectedInstance {
                    instance.isStarred = !instance.isStarred
                }
            }) {
                if viewModel.selectedInstance?.isStarred ?? false {
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
            .onReceive(viewModel.$selectedInstance, perform: { value in
                instanceIsntSelected = value == nil
            })
            .disabled(instanceIsntSelected)
            .keyboardShortcut("f")
            Button(action: {
                // TODO: implement
            }) {
                Label { Text("Launch") } icon: { Image(systemName: "paperplane") }
            }
            .keyboardShortcut(KeyEquivalent.return)
            .disabled(instanceIsntSelected)
            Button(action: {
                if let instance = viewModel.selectedInstance {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: instance.getPath().path)
                }
            }) {
                Label { Text("Open in Finder") } icon: { Image(systemName: "folder") }
            }
            .keyboardShortcut(KeyEquivalent.upArrow)
            .disabled(instanceIsntSelected)
            
            Divider()
            
            Button("Open Instances Folder") {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.shift, .command])
        }
    }
}
