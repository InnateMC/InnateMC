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

import SwiftUI

struct NewVanillaInstanceView: View {
    @Environment(\.versionManifest) var versionManifest: [PartialVersion]
    @EnvironmentObject var launcherData: LauncherData
    @State var showSnapshots = false
    @State var showBeta = false
    @State var showAlpha = false
    @State var selectedVersion: PartialVersion = VersionManifestKey.defaultValue.first!
    @State var name = ""
    @Binding var showNewInstanceSheet: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Form {
                TextField("Name", text: $name).frame(width: 400, height: nil, alignment: .leading).textFieldStyle(RoundedBorderTextFieldStyle())
                Picker("Version", selection: $selectedVersion) {
                    ForEach(versionManifest) { ver in
                        if (ver.type == "old_alpha" && showAlpha
                            || ver.type == "old_beta" && showBeta
                            || ver.type == "snapshot" && showSnapshots
                            || ver.type == "release") {
                            Text(ver.version)
                        }
                    }
                }
                Toggle("Show snapshots", isOn: $showSnapshots)
                Toggle("Show old beta", isOn: $showBeta)
                Toggle("Show old alpha", isOn: $showAlpha)
            }.padding()
            HStack{
                Spacer()
                HStack{
                    Button("Cancel"){
                        showNewInstanceSheet = false
                    }.keyboardShortcut(.cancelAction)
                    Button("Done") {
                        let instance = VanillaInstanceCreator(name: name, versionUrl: URL(string:selectedVersion.url)!, sha1: selectedVersion.sha1, description: nil, data: launcherData)
                        do {
                            launcherData.instances.append(try instance.install())
                            showNewInstanceSheet = false
                        } catch {
                            print("something was thrown sad emojy")
                        }
                        
                    }.keyboardShortcut(.defaultAction)
                }.padding(.trailing).padding(.bottom)
                
            }
        }
    }
}

struct NewVanillaInstanceView_Previews: PreviewProvider {
    static var previews: some View {
        NewVanillaInstanceView(showNewInstanceSheet: Binding.constant(true))
    }
}
