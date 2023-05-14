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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import AppKit

struct ContentView: View {
    private static let nullUuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
    @State var searchTerm: String = ""
    @State var starredOnly = false
    @EnvironmentObject var launcherData: LauncherData
    @State var isSidebarHidden = false
    @State var showNewInstanceSheet: Bool = false
    @State var selectedInstance: Instance? = nil
    @State var selectedAccount: UUID = ContentView.nullUuid
    
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
                .toolbar {
                    ToolbarItemGroup {
                        createLeadingToolbar()
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
            ToolbarItemGroup(placement: .primaryAction) {
                createTrailingToolbar()
            }
        }
    }
    
    @ViewBuilder
    func createInstanceNavigationLink(instance: Instance) -> some View {
        if ((!starredOnly || instance.isStarred) && instance.matchesSearchTerm(searchTerm)) {
            InstanceNavigationLink(instance: instance, selectedInstance: $selectedInstance)
                .tag(instance)
                .padding(.all, 4)
                .frame(width: .infinity)
        }
    }
    
    @ViewBuilder
    func createLeadingToolbar() -> some View {
        Spacer()
        
        Button(action: {
            NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }) {
            Image(systemName: "sidebar.leading")
        }
        
        Toggle(isOn: $starredOnly) {
            if(starredOnly) {
                Image(systemName: "star.fill")
            } else{
                Image(systemName: "star")
            }
        }
        .help(i18n("show_only_starred"))
        
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
    }
    
    @ViewBuilder
    func createTrailingToolbar() -> some View {
        Spacer()
        
        Button(i18n("manage_accounts")) {
            launcherData.selectedPreferenceTab = .accounts
            if #available(macOS 13, *) {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } else {
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            }
        }
        
        Picker(i18n("account"), selection: $selectedAccount) {
            Text(i18n("no_account_selected"))
                .tag(ContentView.nullUuid)
            ForEach(Array(launcherData.accountManager.accounts.values).map({AdaptedAccount(from: $0)})) { value in
                HStack(alignment: .center) {
                    Image("steve")
                    Text(value.username)
                        .font(.title2)
                        .frame(height: 32)
                }
                .padding(.all)
                .tag(value.id)
            }
        }
        .frame(height: 40)
        .onAppear {
            self.selectedAccount = launcherData.accountManager.currentSelected ?? ContentView.nullUuid
        }
        .onReceive(launcherData.accountManager.$currentSelected) {
            self.selectedAccount = $0 ?? ContentView.nullUuid
        }
        .onChange(of: self.selectedAccount) { newValue in
            launcherData.accountManager.currentSelected = newValue == ContentView.nullUuid ? nil : newValue
            DispatchQueue.global(qos: .utility).async {
                launcherData.accountManager.saveThrow()
            }
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
