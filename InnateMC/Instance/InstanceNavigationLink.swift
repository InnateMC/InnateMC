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

struct InstanceNavigationLink: View {
    @EnvironmentObject var launcherData: LauncherData
    @StateObject var instance: Instance
    @Binding var selectedInstance: Instance?
    @State var starHovered: Bool = false
    @State var showDeleteSheet: Bool = false

    var body: some View {
        NavigationLink {
            InstanceView(instance: instance)
                .padding(.top, 10)
        } label: {
            HStack {
                ZStack(alignment: .topTrailing) {
                    if launcherData.globalPreferences.ui.compactList {
                        InstanceLogoView(instance: instance)
                            .frame(width: 32, height: 32)
                    } else {
                        InstanceLogoView(instance: instance)
                            .frame(width: 48, height: 48)
                    }
                    
                    ZStack {
                        if launcherData.launchedInstances.keys.contains(self.instance) {
                            Image(systemName: "arrowtriangle.right.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 8, height: 8)
                        } else if instance.isStarred {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(width: 8, height: 8)
                }
                VStack {
                    HStack {
                        Text(instance.name)
                        Spacer()
                    }
                    HStack {
                        Text(instance.synopsisOrVersion)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .contextMenu {
            if instance.isStarred {
                Button(i18n("unstar")) {
                    withAnimation {
                        instance.isStarred = false
                    }
                }
            } else {
                Button(i18n("star")) {
                    withAnimation {
                        instance.isStarred = true
                    }
                }
            }
            Button(i18n("delete")) {
                showDeleteSheet = true
            }
        }
        .sheet(isPresented: $showDeleteSheet) {
            VStack(alignment: .center) {
                Text(LocalizedStringKey("are_you_sure_delete_instance"))
                HStack {
                    Button(LocalizedStringKey("delete")) {
                        if let index = launcherData.instances.firstIndex(of: instance) {
                            if let selectedInstance = selectedInstance {
                                if selectedInstance.name == self.instance.name {
                                    self.selectedInstance = nil
                                }
                            }
                            launcherData.instances.remove(at: index)
                            instance.delete()
                        }
                        showDeleteSheet = false
                    }
                    .padding()
                    Button(LocalizedStringKey("cancel")) {
                        showDeleteSheet = false
                    }
                    .padding()
                }
            }
            .padding(.all, 20)
        }
    }
}
