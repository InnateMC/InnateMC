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
    @Binding var showErrorSheet: Bool
    @Binding var errorMessageKey: LocalizedStringKey
    @EnvironmentObject var launcherData: LauncherData
    @State var showPreLaunchSheet: Bool = false
    @State var progress: Float = 0
    @State var downloadMessage: LocalizedStringKey = i18n("downloading_libs")
    @State var downloadProgress: TaskProgress = TaskProgress(current: 0, total: 1)
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    @State var launchedInstanceProcess: InstanceProcess? = nil
    @State var showChooseAccountSheet: Bool = false
    @State var downloadSession: URLSession? = nil
    @State var logMessages: [String] = []
    
    var body: some View {
        VStack {
            HStack {
                if let launchedInstanceProcess = launchedInstanceProcess {
                    HStack {
                        Button(action: {
                            // TODO: show a warning message
                            kill(launchedInstanceProcess.process.processIdentifier, SIGKILL)
                            launcherData.launchedInstances.removeValue(forKey: instance)
                        }, label: {
                            Text(i18n("force_quit"))
                                .font(.title2)
                        })
                    }
                    .onReceive(launchedInstanceProcess.$terminated, perform: { value in
                        if value {
                            self.launchedInstanceProcess = nil
                            launcherData.launchedInstances.removeValue(forKey: instance)
                        }
                    })
                } else {
                    Button(action: {
                        launcherData.instanceLaunchRequested = true
                    }, label: {
                        Text(i18n("launch"))
                            .font(.title2)
                    })
                }
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstances = value
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .onReceive(launcherData.$instanceLaunchRequested) { value in
                if value {
                    if launcherData.accountManager.currentSelected != nil {
                        showPreLaunchSheet = true
                        downloadProgress.cancelled = false
                        launcherData.instanceLaunchRequested = false
                    } else {
                        showChooseAccountSheet = true
                    }
                }
            }
            .onAppear {
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .padding()
            if launchedInstanceProcess != nil {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(self.logMessages, id: \.self) { message in
                                Text(message)
                                    .font(.system(.body, design: .monospaced))
                                    .id(message)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .id(self.logMessages)
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                    )
                    .padding(.all, 7.0)
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(self.logMessages.last, anchor: .bottom)
                        }
                        self.logMessages = self.launchedInstanceProcess!.logMessages
                    }
                    .onReceive(self.launchedInstanceProcess!.$logMessages) {
                        self.logMessages = $0
                    }
                }
            }
            Spacer()
        }
        .sheet(isPresented: $showPreLaunchSheet, content: createPrelaunchSheet)
        .sheet(isPresented: $showChooseAccountSheet, content: createChooseAccountSheet)
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
                Button(i18n("abort")) {
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
        downloadMessage = i18n("downloading_libs")
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = i18n("downloading_assets")
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = i18n("extracting_natives")
                downloadProgress.callback = {
                    showPreLaunchSheet = false
                    if !(downloadProgress.cancelled) {
                        withAnimation {
                            let process = InstanceProcess(instance: instance, account: launcherData.accountManager.selectedAccount)
                            launcherData.launchedInstances[instance] = process
                            launchedInstanceProcess = process
                        }
                    }
                    downloadProgress.callback = {}
                }
                instance.extractNatives(progress: downloadProgress)
            } onError: {
                onPrelaunchError($0)
            }
        } onError: {
            onPrelaunchError($0)
        }
    }
    
    func onPrelaunchError(_ error: ParallelDownloadError) {
        if (showErrorSheet) {
            return
        }
        showPreLaunchSheet = false
        showErrorSheet = true
        switch(error) {
        case .downloadFailed(let errorKey):
            errorMessageKey = LocalizedStringKey(errorKey)
            break
        }
    }
    
    @ViewBuilder
    func createChooseAccountSheet() -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    Text(i18n("no_account_selected"))
                    Spacer()
                }
                .padding()
                Button(i18n("close")) {
                    self.showChooseAccountSheet = false
                }
                .keyboardShortcut(.cancelAction)
                .padding()
            }
        }
    }
}
