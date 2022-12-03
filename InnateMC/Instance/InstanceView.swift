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
import InnateKit

struct InstanceView: View {
    @State var instance: Instance
    @AppStorage("innatemc.rightAlignedInstanceHeading") private var rightAlignedInstanceHeading: Bool = false
    @State var disabled: Bool = false
    @State var showingInstallSheet: Bool = false
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    if !rightAlignedInstanceHeading {
                        Spacer()
                    }
                    Text(instance.name)
                        .font(.largeTitle)
                    if instance.isStarred {
                        Image(systemName: "star.fill")
                            .resizable()
                            .foregroundColor(.yellow)
                            .onTapGesture {
                                instance.isStarred = false
                            }
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: "star")
                            .resizable()
                            .foregroundColor(.gray)
                            .onTapGesture {
                                instance.isStarred = true
                            }
                            .frame(width: 16, height: 16)
                    }
                    Spacer()
                }
                HStack {
                    if !rightAlignedInstanceHeading {
                        Spacer()
                    }
                    Text(instance.someDebugString)
                        .font(.caption)
                        .padding(.all, 6)
                        .foregroundColor(.gray)
                    Spacer()
                }
                HStack {
                    if instance.description != nil {
                        Text(instance.description!)
                            .font(.body)
                    }
                    Spacer()
                }
                Spacer()
                TabView {
                    VStack {
                        HStack {
                            Button(action: {
                                showingInstallSheet = true
//                                let _ = try! instance.downloadMcJar()
//                                viewModel.currentDownloadStatus = "Downloading Assets"
//                                let _ = try! instance.downloadAssets(progress: viewModel.currentDownloadProgress) {
//                                    viewModel.currentDownloadStatus = "Downloading Libraries"
//                                    let _ = instance.downloadLibs(progress: viewModel.currentDownloadProgress, callback: {
//                                        showingInstallSheet = false
//                                        viewModel.currentDownloadProgress.current = 0
//                                        viewModel.currentDownloadProgress.total = 1
//                                        viewModel.currentDownloadStatus = "Downloading"
//                                    })
//                                }
                            }, label: {
                                Text("Launch")
                                    .font(.title2)
                            })
                        }
                    }
                    .tabItem {
                        Label("Launch", systemImage: "bolt")
                    }
                    TodoView()
                        .tabItem {
                            Label("Runtime", systemImage: "bolt")
                        }
                    TodoView()
                        .tabItem {
                            Label("Mods", systemImage: "bolt")
                        }
                    TodoView()
                        .tabItem {
                            Label("Resource Packs", systemImage: "bolt")
                        }
                    TodoView()
                        .tabItem {
                            Label("Worlds", systemImage: "bolt")
                        }
                    TodoView()
                        .tabItem {
                            Label("Screenshots", systemImage: "bolt")
                        }
                    TodoView()
                        .tabItem {
                            Label("Misc", systemImage: "bolt")
                        }
                }.padding(.all, 4)
            }
            .sheet(isPresented: $showingInstallSheet) {
                LoadingSheet()
                    .environmentObject(self.viewModel)
            }
            .padding(.all, 6)
        }
    }
}

struct InstanceView_Previews: PreviewProvider {
    static var previews: some View {
        let instance: Instance = Instance(name: "Test Instance", assetIndex: PartialAssetIndex(id: "bruh", sha1: "bruh", url: "bruh"), libraries: [], mainClass: "bruh", minecraftJar: MinecraftJar(type: .local, url: nil, sha1: nil), isStarred: false, logo: "", description: "e this won't run lol", debugString: "c0.21, Textile")
        InstanceView(instance: instance)
            .frame(width: 600, height: 500)
    }
}
