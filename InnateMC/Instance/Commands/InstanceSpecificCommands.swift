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

struct InstanceSpecificCommands: View {
    @FocusedValue(\.selectedInstance) private var selectedInstance: Instance?
    @State private var instanceIsntSelected: Bool = true
    @State private var instanceStarred: Bool = false
    @State private var instanceIsntLaunched: Bool = true
    @State private var instanceIsntInEdit: Bool = true
    
    var body: some View {
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
                self.instanceIsntLaunched = !LauncherData.instance.launchedInstances.contains(where: { $0.0 == newValue })
                self.instanceIsntInEdit = !LauncherData.instance.editModeInstances.contains(where: { $0 == newValue })
            } else {
                self.instanceStarred = false
                self.instanceIsntLaunched = true
                self.instanceIsntInEdit = true
            }
            self.instanceIsntSelected = newValue == nil
        }
        .onReceive(LauncherData.instance.$launchedInstances) { value in
            if let selectedInstance = selectedInstance {
                self.instanceIsntLaunched = !value.contains(where: { $0.0 == self.selectedInstance })
            } else {
                self.instanceIsntLaunched = true
            }
        }
        .onReceive(LauncherData.instance.$editModeInstances) { value in
            if let selectedInstance = selectedInstance {
                self.instanceIsntInEdit = !value.contains(where: { $0 == self.selectedInstance })
            } else {
                self.instanceIsntInEdit = true
            }
        }
        
        if instanceIsntLaunched {
            Button {
                LauncherData.instance.launchRequestedInstances.append(selectedInstance!)
            } label: {
                Text(i18n("launch"))
                Image(systemName: "paperplane")
            }
            .keyboardShortcut(KeyEquivalent.return)
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.killRequestedInstances.append(selectedInstance!)
            } label: {
                Text(i18n("kill"))
                Image(systemName: "square.fill")
            }
        }
        
        if instanceIsntInEdit {
            Button {
                LauncherData.instance.editModeInstances.append(selectedInstance!)
            } label: {
                Text(i18n("edit"))
                Image(systemName: "pencil")
            }
            .keyboardShortcut(KeyEquivalent("e"))
            .disabled(selectedInstance == nil)
        } else {
            Button {
                LauncherData.instance.editModeInstances.removeAll(where: { $0 == selectedInstance! })
            } label: {
                Text(i18n("save"))
                Image(systemName: "checkmark")
            }
            .keyboardShortcut(KeyEquivalent("s"))
        }
        
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
