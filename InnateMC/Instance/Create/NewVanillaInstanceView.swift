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
    @State var selectedVersion: PartialVersion = VersionManifest.downloadThrow().first!
    @State var name = ""
    @State var versions: [PartialVersion] = []
    @Binding var showNewInstanceSheet: Bool
    @State var showNoNamePopover = false
    @State var showDuplicateNamePopover = false
    
    var body: some View {
        VStack {
            Spacer()
            Form {
                TextField(i18n("name"), text: $name).frame(width: 400, height: nil, alignment: .leading).textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: $showNoNamePopover, arrowEdge: .bottom) {
                        Text("Enter a name")
                            .padding()
                    }
                    .popover(isPresented: $showDuplicateNamePopover, arrowEdge: .bottom) {
                        Text("Enter a unique name")
                            .padding()
                    }
                Picker(i18n("version"), selection: $selectedVersion) {
                    ForEach(self.versions) { ver in
                        Text(ver.version)
                            .tag(ver)
                    }
                }
                Toggle(i18n("show_snapshots"), isOn: $showSnapshots)
                Toggle(i18n("show_old_beta"), isOn: $showBeta)
                Toggle(i18n("show_old_alpha"), isOn: $showAlpha)
            }.padding()
            HStack{
                Spacer()
                HStack{
                    Button(i18n("cancel")) {
                        showNewInstanceSheet = false
                    }.keyboardShortcut(.cancelAction)
                    Button(i18n("done")) {
                        let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedName.isEmpty { // TODO: also check for spaces
                            showNoNamePopover = true
                        } else {
                            showNoNamePopover = false
                            let instance = VanillaInstanceCreator(name: trimmedName, versionUrl: URL(string:selectedVersion.url)!, sha1: selectedVersion.sha1, description: nil, data: launcherData)
                            do {
                                launcherData.instances.append(try instance.install())
                                showNewInstanceSheet = false
                            } catch {
                                // TODO: handle this error
                                print("something was thrown sad emojy")
                            }
                        }
                    }.keyboardShortcut(.defaultAction)
                }.padding(.trailing).padding(.bottom)
                
            }
        }
        .onAppear {
            recomputeVersions()
        }
        .onChange(of: showAlpha) { _ in
            recomputeVersions()
        }
        .onChange(of: showBeta) { _ in
            recomputeVersions()
        }
        .onChange(of: showSnapshots) { _ in
            recomputeVersions()
        }
    }
    
    func recomputeVersions() {
        DispatchQueue.global().async {
            let newVersions = self.versionManifest.filter { version in
                return version.type == "old_alpha" && showAlpha ||
                version.type == "old_beta" && showBeta ||
                version.type == "snapshot" && showSnapshots ||
                version.type == "release"
            }
            let notContained = !newVersions.contains(self.selectedVersion)
            DispatchQueue.main.async {
                self.versions = newVersions
                if notContained {
                    self.selectedVersion = newVersions.first!
                }
            }
        }
    }
}

struct NewVanillaInstanceView_Previews: PreviewProvider {
    static var previews: some View {
        NewVanillaInstanceView(showNewInstanceSheet: Binding.constant(true))
    }
}
