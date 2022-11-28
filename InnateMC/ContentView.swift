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

struct ContentView: View {
    @State public var searchTerm: String = ""
    @State private var showNew = false

    var body: some View {
        NavigationView {
            List {
                TextField("Search...", text: $searchTerm)
                    .padding(.bottom, 10.0)
                    .accessibilityLabel("Search for Instance")
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Toggle(isOn: .constant(false)) {
                    Text("Starred only")
                }
                NavigationLink("Mint") {
                    Text("bruh")
                }
                NavigationLink("Winter") {
                    Text("huh???")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
