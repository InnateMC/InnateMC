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
    
    @State public var starredOnly = false
    @State public var selectedInstance: Instance?
    @EnvironmentObject var viewModel: ViewModel
    var index: Int? {
        viewModel.instances.firstIndex(where: { $0.id == selectedInstance?.id })
    }
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(viewModel.instances) { instance in
                    if ((!starredOnly || instance.isStarred) && (searchTerm.isEmpty || instance.checkMatch(searchTerm))) {
                        NavigationLink(destination: {
                            InstanceView(instance: instance)
                                .padding(.top, 10)
                        }, label: {
                            InstanceNavigationLink(instance: instance)
                        })
                            .tag(instance)
                            .padding(.all, 4)
                    }
                }
            }
            .sheet(isPresented:$viewModel.showNewInstanceScreen){
                NewInstanceView()
            }
            .navigationTitle("Instances").toolbar{
                
                
                Spacer()
                Toggle(isOn: $starredOnly) {
                    if(starredOnly){
                        Image(systemName: "star.fill")
                    }else{
                        Image(systemName: "star")
                    }
                    
                }
                Button(action:{viewModel.showNewInstanceScreen = true}) {
                    Image(systemName: "plus")
                }
                .keyboardShortcut("n")
            }
            
            Text("Select an instance")
                .font(.largeTitle)
                .foregroundColor(.gray)
        }
//        .searchable(text: $searchTerm,placement: .sidebar)
    }
}
