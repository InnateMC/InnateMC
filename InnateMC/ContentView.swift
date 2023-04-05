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
    @State var searchTerm: String = ""
    @State var starredOnly = false
    @EnvironmentObject var launcherData: LauncherData
    @State var instances: [Instance] = []
    
    var body: some View {
        NavigationView {
            VStack {
                createMacOS11TextField()
                List {
                    ForEach(instances) { instance in
                        createInstanceNavigationLink(instance: instance)
                    }
                    .onMove { indices, newOffset in
                        launcherData.instances.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .onReceive(launcherData.$instances) { new in
                    instances = new
                }
            }
            .sheet(isPresented: $launcherData.showNewInstanceSheet) {
                NewInstanceView()
            }
            .navigationTitle("Instances")
            .toolbar { createToolbar() }
            
            Text("Select an instance")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .macOS12Searchable(text: $searchTerm)
    }
    
    @ViewBuilder
    func createInstanceNavigationLink(instance: Instance) -> some View {
        if ((!starredOnly || instance.isStarred) && (searchTerm.isEmpty || instance.checkMatch(searchTerm))) {
            NavigationLink(destination: {
                InstanceView(instance: instance)
                    .padding(.top, 10)
            }){
                InstanceNavigationLink(instance: instance)
            }
            .tag(instance)
            .padding(.all, 4)
        }
    }
    
    @ViewBuilder
    func createToolbar() -> some View {
        Spacer()
        Toggle(isOn: $starredOnly) {
            if(starredOnly) {
                Image(systemName: "star.fill")
            } else{
                Image(systemName: "star")
            }
        }
        Button(action:{launcherData.showNewInstanceSheet = true}) {
            Image(systemName: "plus")
        }
    }
    
    @ViewBuilder
    func createMacOS11TextField() -> some View {
        if #available(macOS 12.0, *) {
        } else {
            TextField("Search", text: $searchTerm)
                .padding(.trailing, 8.0)
                .padding(.leading, 10.0)
                .padding([.top, .bottom], 9.0)
                .frame(height: 80)
                .accessibilityLabel("Search for Instance")
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

extension NavigationView {
    @ViewBuilder
    func macOS12Searchable(text: Binding<String>) -> some View {
        if #available(macOS 12.0, *) {
            self.searchable(text: text, placement: .sidebar)
        } else {
            self
        }
    }
}
