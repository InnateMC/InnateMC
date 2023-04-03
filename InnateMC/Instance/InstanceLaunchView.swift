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

struct InstanceLaunchView: View {
    var instance: Instance
    @EnvironmentObject var launcherData: LauncherData
    @State var showPreLaunchSheet: Bool = false
    @State var progress: Float = 0
    @State var downloadMessage: String = "Downloading Libraries..."
    @State var downloadProgress: TaskProgress = TaskProgress(current: 0, total: 1)
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    
    var body: some View {
        VStack {
            HStack {
                if (launchedInstances ?? launcherData.launchedInstances).keys.contains(instance) {
                    Button(action: {
                        // TODO: show a warning message
                        launcherData.launchedInstances.removeValue(forKey: instance)
                    }, label: {
                        Text("Kill")
                            .font(.title2)
                    })
                } else {
                    Button(action: {
                        print(instance.getPath().absoluteString)
                        showPreLaunchSheet = true
                        downloadProgress.cancelled = false
                    }, label: {
                        Text("Launch")
                            .font(.title2)
                    })
                }
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstances = value
            }
        }
        .sheet(isPresented: $showPreLaunchSheet) {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Text(downloadMessage)
                        Spacer()
                    }
                    .padding()
                    ProgressView(value: progress)
                        .onReceive(downloadProgress.$current, perform: {
                            progress = Float($0) / Float(downloadProgress.total)
                        })
                        .animation(nil)
                    Button("Abort") {
                        showPreLaunchSheet = false
                        self.downloadProgress.cancelled = true
                        self.downloadProgress = TaskProgress(current: 0, total: 1)
                    }
                    .padding()
                }
            }
            // TODO: error handling
            .onAppear(perform: {
                downloadMessage = "Downloading Libraries..."
                downloadProgress.callback = {
                    downloadMessage = "Downloading Assets..."
                    downloadProgress.callback = {
                        downloadMessage = "Extracting Natives..."
                        downloadProgress.callback = {
                            showPreLaunchSheet = false
                            if !(downloadProgress.cancelled) {
                                withAnimation {
                                    launcherData.launchedInstances[instance] = InstanceProcess(instance: instance)
                                }
                            }
                            downloadProgress.callback = {}
                        }
                        // DO SOMETHING
                    }
                    try! instance.downloadAssets(progress: downloadProgress, callback: {})
                }
                instance.downloadLibs(progress: downloadProgress, callback: {})
            })
            .padding(.all, 10)
        }
    }
}
