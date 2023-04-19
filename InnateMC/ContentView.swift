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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State var searchTerm: String = ""
    @State var starredOnly = false
    @EnvironmentObject var launcherData: LauncherData
    @State var isSidebarHidden = false
    @State var showNewInstanceSheet: Bool = false
    @State var tempSel: String = "e"
    @State var selectedInstance: Instance? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(i18n("search"), text: $searchTerm)
                    .padding(.trailing, 8.0)
                    .padding(.leading, 10.0)
                    .padding([.top, .bottom], 9.0)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                List(selection: $selectedInstance) {
                    ForEach(launcherData.instances) { instance in
                        createInstanceNavigationLink(instance: instance)
                    }
                    .onMove { indices, newOffset in
                        launcherData.instances.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
            }
            .sheet(isPresented: $showNewInstanceSheet) {
                NewInstanceView(showNewInstanceSheet: $showNewInstanceSheet)
            }
            .navigationTitle(i18n("instances_title"))
            
            Text(i18n("select_an_instance"))
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .bindInstanceFocusValue(selectedInstance)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                createLeadingToolbar() // TODO: move this to on top of the sidebar somehow
            }
            ToolbarItemGroup(placement: .primaryAction) {
                createTrailingToolbar()
            }
        }
    }
    
    @ViewBuilder
    func createTrailingToolbar() -> some View {
        Spacer()
        Button(i18n("manage_accounts")) {
            launcherData.selectedPreferenceTab = .accounts
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        Picker(i18n("account"), selection: $tempSel) {
            ForEach(launcherData.instances) { thing in // TODO: implement
                HStack(alignment: .center) {
                    Image("steve")
                    Text("Dev\(thing.name)")
                        .font(.title2)
                }
                .padding(.all)
                .tag(thing.name)
            }
        }
        .frame(height: 40)
    }
    
    @ViewBuilder
    func createInstanceNavigationLink(instance: Instance) -> some View {
        if ((!starredOnly || instance.isStarred) && instance.matchesSearchTerm(searchTerm)) {
            InstanceNavigationLink(instance: instance)
                .tag(instance)
                .padding(.all, 4)
                .frame(width: .infinity)
        }
    }
    
    @ViewBuilder
    func createLeadingToolbar() -> some View {
        Spacer()
        Toggle(isOn: $starredOnly) {
            if(starredOnly) {
                Image(systemName: "star.fill")
            } else{
                Image(systemName: "star")
            }
        }
        Button(action: {
            showNewInstanceSheet = true
        }) {
            Image(systemName: "plus")
        }.onReceive(launcherData.$newInstanceRequested) { req in
            if req {
                showNewInstanceSheet = true
                launcherData.newInstanceRequested = false
            }
        }
        
        Button(action: {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }) {
            Image(systemName: "sidebar.leading")
        }
    }
}

extension NavigationView {
    @ViewBuilder
    func bindInstanceFocusValue(_ i: Instance?) -> some View {
        if #available(macOS 13, *) {
            self.focusedValue(\.selectedInstance, i)
        } else {
            self
        }
    }
}

func i18n(_ str: String) -> LocalizedStringKey {
    return LocalizedStringKey(str)
}
