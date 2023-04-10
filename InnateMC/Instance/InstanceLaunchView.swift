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
    @State var downloadMessage: String = "Downloading Libraries"
    @State var downloadProgress: TaskProgress = TaskProgress(current: 0, total: 1)
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    @State var launchedInstanceProcess: InstanceProcess? = nil
    @State var showErrorSheet: Bool = false
    @State var errorMessage: String = "Never gonna give you up"
    @State var downloadSession: URLSession? = nil
    
    var body: some View {
        VStack {
            HStack {
                if launchedInstanceProcess != nil {
                    Button(action: {
                        // TODO: show a warning message
                        let launchData = launcherData.launchedInstances[instance]
                        launchData?.process.interrupt()
                        launcherData.launchedInstances.removeValue(forKey: instance)
                    }, label: {
                        Text("Close")
                            .font(.title2)
                    })
                        .onReceive(launchedInstanceProcess!.$terminated, perform: { value in
                            if value {
                                launchedInstanceProcess = nil
                                launcherData.launchedInstances.removeValue(forKey: instance)
                            }
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
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .onAppear {
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
        }
        .sheet(isPresented: $showPreLaunchSheet) {
            createPrelaunchSheet()
        }
        .sheet(isPresented: $showErrorSheet) {
            createErrorSheet()
        }
    }
    
    @ViewBuilder
    func createPrelaunchSheet() -> some View {
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
                    self.downloadSession?.invalidateAndCancel()
                    showPreLaunchSheet = false
                    self.downloadProgress.cancelled = true
                    self.downloadProgress = TaskProgress(current: 0, total: 1)
                }
                .padding()
            }
        }
        // TODO: error handling
        .onAppear(perform: {
            onPrelaunchSheetAppear()
        })
        .padding(.all, 10)
    }
    
    func onPrelaunchSheetAppear() {
        self.downloadProgress.cancelled = false
        downloadMessage = "Downloading Libraries"
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = "Downloading Assets"
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = "Extracting Natives"
                downloadProgress.callback = {
                    showPreLaunchSheet = false
                    if !(downloadProgress.cancelled) {
                        withAnimation {
                            let process = InstanceProcess(instance: instance)
                            launcherData.launchedInstances[instance] = process
                            launchedInstanceProcess = process
                        }
                    }
                    downloadProgress.callback = {}
                }
                instance.extractNatives(progress: downloadProgress)
            } onError: {
                onPrelaunchError()
            }
        } onError: {
            onPrelaunchError()
        }
    }
    
    func onPrelaunchError() {
        if (showErrorSheet) {
            return
        }
        showPreLaunchSheet = false
        showErrorSheet = true
    }
    
    @ViewBuilder
    func createErrorSheet() -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Error launching")
                    Spacer()
                }
                .padding()
                Button("Close") {
                    self.showErrorSheet = false
                }
                .padding()
            }
        }
    }
}
