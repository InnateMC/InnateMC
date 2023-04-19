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
import Combine

struct InstanceCommands: Commands {
    public var launcherData: LauncherData
    @State private var instanceIsntSelected: Bool = false
    @FocusedValue(\.selectedInstance) private var selectedInstance: Instance?
    @State private var instanceStarred: Bool = false

    var body: some Commands {
        CommandMenu(i18n("instance")) {
            if #available(macOS 13, *) {
                buildSpecificCommands()
            }
            
            Button(i18n("open_instances_folder")) {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: FileHandler.instancesFolder.path)
            }
            .keyboardShortcut(KeyEquivalent.upArrow, modifiers: [.shift, .command])
            Button(i18n("new_instance")) {
                DispatchQueue.main.async {
                    launcherData.newInstanceRequested = true
                }
            }
            .keyboardShortcut("n")
        }
    }
    
    @ViewBuilder
    func buildSpecificCommands() -> some View {
        Button(action: {
            if let instance = selectedInstance {
                withAnimation {
                    instance.isStarred = !instance.isStarred
                }
            }
        }) {
            if instanceStarred {
                Text(i18n("unstar"))
                Image(systemName: "star.slash")
            } else {
                Text(i18n("star"))
                Image(systemName: "star")
            }
        }
        .disabled(selectedInstance == nil)
        .keyboardShortcut("f")
        .onChange(of: selectedInstance) { newValue in
            if let newValue = newValue {
                self.instanceStarred = newValue.isStarred
            }
        }
        Button(action: {
            launcherData.instanceLaunchRequested = true
        }) {
            Text(i18n("launch"))
            Image(systemName: "paperplane")
        }
        .keyboardShortcut(KeyEquivalent.return)
        .disabled(selectedInstance == nil)
        Button(action: {
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: selectedInstance!.getPath().path)
        }) {
            Text(i18n("open_in_finder"))
            Image(systemName: "folder")
        }
        .keyboardShortcut(KeyEquivalent.upArrow)
        .disabled(selectedInstance == nil)
        
        if let selectedInstance = selectedInstance {
            Divider()
                .onReceive(selectedInstance.$isStarred) { value in
                    self.instanceStarred = value
                }
        } else {
            Divider()
        }
    }
}
