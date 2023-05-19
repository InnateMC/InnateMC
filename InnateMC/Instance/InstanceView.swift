//
// Copyright © 2022 InnateMC and contributors
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

struct InstanceView: View {
    @StateObject var instance: Instance
    @State var disabled: Bool = false
    @EnvironmentObject var launcherData: LauncherData
    @State var starHovered: Bool = false
    @State var logoHovered: Bool = false
    @State var showLogoSheet: Bool = false
    @StateObject var editingViewModel = InstanceEditingViewModel()
    @State var showNoNamePopover: Bool = false
    @State var showDuplicatePopover: Bool = false
    @State var showErrorSheet: Bool = false
    @State var showPreLaunchSheet: Bool = false
    @State var showChooseAccountSheet: Bool = false
    @State var launchError: LaunchError? = nil
    @State var downloadSession: URLSession? = nil
    @State var downloadMessage: LocalizedStringKey = i18n("downloading_libs")
    @State var downloadProgress: TaskProgress = TaskProgress(current: 0, total: 1)
    @State var progress: Float = 0
    @State var launchedInstanceProcess: InstanceProcess? = nil
    @State var indeterminateProgress: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    InstanceInterativeLogoView(instance: self.instance, showLogoSheet: $showLogoSheet, logoHovered: $logoHovered)
                    VStack {
                        HStack {
                            InstanceTitleView(editingViewModel: self.editingViewModel, instance: self.instance, showNoNamePopover: $showNoNamePopover, showDuplicatePopover: $showDuplicatePopover, starHovered: $starHovered)
                            Spacer()
                        }
                        HStack {
                            InstanceSynopsisView(editingViewModel: self.editingViewModel, instance: self.instance)
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                .sheet(isPresented: $showLogoSheet) {
                    InstanceLogoSheet(instance: self.instance, showLogoSheet: $showLogoSheet)
                }
                HStack {
                    InstanceNotesView(editingViewModel: self.editingViewModel, instance: self.instance)
                    Spacer()
                }
                Spacer()
                TabView {
                    InstanceConsoleView(instance: instance, launchedInstanceProcess: $launchedInstanceProcess)
                        .tabItem {
                            Label(i18n("console"), systemImage: "bolt")
                        }
                    InstanceRuntimeView(instance: instance)
                        .tabItem {
                            Label(i18n("runtime"), systemImage: "bolt")
                        }
                }.padding(.all, 4)
            }
            .padding(.all, 6)
            .onAppear {
                launcherData.launchRequestedInstances.removeAll(where: { $0 == self.instance })
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .sheet(isPresented: $showErrorSheet) {
                LaunchErrorSheet(launchError: $launchError, showErrorSheet: $showErrorSheet)
            }
            .sheet(isPresented: $showPreLaunchSheet, content: createPrelaunchSheet)
            .sheet(isPresented: $showChooseAccountSheet) {
                InstanceChooseAccountSheet(showChooseAccountSheet: $showChooseAccountSheet)
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
            .onReceive(launcherData.$launchRequestedInstances) { value in
                if value.contains(where: { $0 == self.instance}) {
                    if launcherData.accountManager.currentSelected != nil {
                        showPreLaunchSheet = true
                        downloadProgress.cancelled = false
                    } else {
                        showChooseAccountSheet = true
                    }
                    launcherData.launchRequestedInstances.removeAll(where: { $0 == self.instance })
                }
            }
            .onReceive(launcherData.$editModeInstances) { value in
                if value.contains(where: { $0 == self.instance}) {
                    self.editingViewModel.start(from: self.instance)
                } else if self.editingViewModel.inEditMode {
                    self.editingViewModel.commit(to: self.instance, showNoNamePopover: $showNoNamePopover, showDuplicateNamePopover: $showDuplicatePopover, data: self.launcherData)
                }
            }
            .onReceive(launcherData.$killRequestedInstances) { value in
                if value.contains(where: { $0 == self.instance})  {
                    kill(launchedInstanceProcess!.process.processIdentifier, SIGKILL)
                    launcherData.killRequestedInstances.removeAll(where: { $0 == self.instance })
                }
            }
        }
    }
    
    @ViewBuilder
    func createPrelaunchSheet() -> some View {
        VStack {
            HStack {
                Spacer()
                Text(downloadMessage)
                Spacer()
            }
            .padding()
            if indeterminateProgress {
                ProgressView()
                    .progressViewStyle(.linear)
            } else {
                ProgressView(value: progress)
            }
            Button(i18n("abort")) {
                logger.info("Aborting instance launch")
                self.downloadSession?.invalidateAndCancel()
                showPreLaunchSheet = false
                self.downloadProgress.cancelled = true
                self.downloadProgress = TaskProgress(current: 0, total: 1)
            }
            .onReceive(downloadProgress.$current, perform: {
                progress = Float($0) / Float(downloadProgress.total)
            })
            .padding()
        }
        .onAppear(perform: {
            onPrelaunchSheetAppear()
        })
        .padding(.all, 10)
    }
    
    func onPrelaunchSheetAppear() {
        logger.info("Preparing to launch \(self.instance.name)")
        self.indeterminateProgress = false
        self.downloadProgress.cancelled = false
        downloadMessage = i18n("downloading_libs")
        logger.info("Downloading libraries")
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = i18n("downloading_assets")
            logger.info("Downloading assets")
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = i18n("extracting_natives")
                logger.info("Extracting natives")
                downloadProgress.callback = {
                    if !downloadProgress.cancelled {
                        self.indeterminateProgress = true
                        downloadMessage = i18n("authenticating_with_minecraft")
                        logger.info("Fetching access token")
                        Task(priority: .high) {
                            do {
                                let accessToken = try await launcherData.accountManager.selectedAccount.createAccessToken()
                                DispatchQueue.main.async {
                                    withAnimation {
                                        let process = InstanceProcess(instance: instance, account: launcherData.accountManager.selectedAccount, accessToken: accessToken)
                                        launcherData.launchedInstances[instance] = process
                                        launchedInstanceProcess = process
                                        showPreLaunchSheet = false
                                    }
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    onPrelaunchError(.accessTokenFetchError(error: error))
                                }
                            }
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
    
    @MainActor
    func onPrelaunchError(_ error: LaunchError) {
        if (self.showErrorSheet) {
            logger.debug("Suppressed error during prelaunch: \(error.localizedDescription)")
            if let sup = error.cause {
                logger.debug("Cause: \(sup.localizedDescription)")
            }
            return
        }
        logger.error("Caught error during prelaunch", error: error)
        ErrorTracker.instance.error(error: error, description: "Caught error during prelaunch")
        if let cause = error.cause {
            logger.error("Cause", error: cause)
            ErrorTracker.instance.error(error: error, description: "Causative error during prelaunch")
        }
        self.showPreLaunchSheet = false
        self.showErrorSheet = true
        self.downloadProgress.cancelled = true
        self.launchError = error
    }
}
