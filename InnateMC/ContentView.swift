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
    @State var selectedInstance: Instance? = nil
    @FocusedValue(\.selectedInstance) private var focusedSelectedInstance: Instance?
    
    var body: some View {
        NavigationView {
            VStack {
                if #available(macOS 12.0, *) {
                } else {
                    TextField("Search...", text: $searchTerm)
                        .padding([.top, .bottom, .trailing], 8.0)
                        .padding(.leading, 10.0)
                        .accessibilityLabel("Search for Instance")
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                List {
                    ForEach(instances) { instance in
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
                    .onMove { indices, newOffset in
                        instances.move(fromOffsets: indices, toOffset: newOffset)
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
            .navigationTitle("Instances").toolbar{
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
            
            Text("Select an instance")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
        .probablySearchable(text: $searchTerm)
    }
}

extension NavigationView {
    @ViewBuilder
    func probablySearchable(text: Binding<String>) -> some View {
        if #available(macOS 12.0, *) {
            self.searchable(text: text, placement: .sidebar)
        } else {
            self
        }
    }
}
