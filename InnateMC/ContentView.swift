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
import InnateKit

struct ContentView: View {
    @State public var searchTerm: String = ""
    @State public var showNew = false
    @State public var starredOnly = false
    @Environment(\.instances) public var instances: [Instance]

    var body: some View {
        NavigationView {
            List {
                TextField("Search...", text: $searchTerm)
                    .padding(.bottom, 10.0)
                    .accessibilityLabel("Search for Instance")
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Toggle(isOn: $starredOnly) {
                    Text("Starred only")
                }
                ForEach(instances) { instance in
                    if ((!starredOnly || instance.isStarred) && (searchTerm.isEmpty || instance.checkMatch(searchTerm))) {
                        NavigationLink(destination: {
                            InstanceView(instance: instance)
                                .padding(.top, 10)
                        }, label: {
                            InstanceNavigationLink(instance: instance)
                        })
                            .padding(.all, 4)
                    }
                }
            }
            .background(
                NavigationLink(isActive: $showNew, destination: {
                    NewInstanceView()
                }, label: { Text("") })
            )
            .navigationTitle("Instances")
            .toolbar {
                ToolbarItemGroup(placement: ToolbarItemPlacement.navigation) {
                    Button("New Instance") {
                        self.showNew = true
                    }
                    .keyboardShortcut("n")
                    Button("Preferences") {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }
            }
            Text("Select an instance")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
