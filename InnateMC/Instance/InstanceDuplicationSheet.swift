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

import Foundation
import SwiftUI

struct InstanceDuplicationSheet: View {
    @EnvironmentObject var launcherData: LauncherData
    @Binding var showDuplicationSheet: Bool
    @StateObject var instance: Instance
    @State var newName: String = ""
    
    var body: some View {
        VStack {
            // TODO: allow selecting what and what not to duplicate
            Form {
                TextField(i18n("name"), text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            HStack {
                Button(i18n("duplicate")) {
                    let newInstance = Instance(name: self.newName, assetIndex: instance.assetIndex, libraries: instance.libraries, mainClass: instance.mainClass, minecraftJar: instance.minecraftJar, isStarred: false, logo: instance.logo, description: instance.notes, debugString: instance.debugString, gameArguments: instance.gameArguments)
                    DispatchQueue.global().async {
                        do {
                            try newInstance.save()
                        } catch {
                            NSLog("Error duplicating instance")
                            return
                        }
                    }
                    self.launcherData.instances.append(newInstance)
                    self.showDuplicationSheet = false
                }
                .padding()
                Button(i18n("cancel")) {
                    self.showDuplicationSheet = false
                }
                .padding()
            }
        }
        .onAppear {
            self.newName = "Copy of \(instance.name)"
        }
    }
}
