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

struct InstanceLaunchView: View {
    var instance: Instance
    @EnvironmentObject var viewModel: ViewModel
    @State var showPreLaunchSheet: Bool = false
    @State var progress: Float = 0
    @State var downloadMessage: String = "Downloading Libraries..."
    @State var downloadProgress: DownloadProgress = DownloadProgress(current: 0, total: 1)
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    print(instance.getPath().absoluteString)
                    showPreLaunchSheet = true
                }, label: {
                    Text("Launch")
                        .font(.title2)
                })
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
                        self.downloadProgress = DownloadProgress(current: 0, total: 1)
                    }
                    .padding()
                }
            }
            // TODO: error handling
            .onAppear(perform: {
                downloadProgress.callback = {
                    downloadMessage = "Downloading Assets..."
                    downloadProgress.callback = {
                        print("bruh2")
                        showPreLaunchSheet = false
                        downloadProgress.callback = {}
                    }
                    try! instance.downloadAssets(progress: downloadProgress, callback: {})
                }
                instance.downloadLibs(progress: downloadProgress, callback: {})
                try! instance.downloadMcJar()
            })
            .padding(.all, 10)
        }
    }
}
