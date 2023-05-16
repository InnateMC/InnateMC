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
                    createLogo()
                    VStack {
                        HStack {
                            if editingViewModel.inEditMode {
                                TextField(i18n("name"), text: $editingViewModel.name)
                                    .font(.largeTitle)
                                    .labelsHidden()
                                    .fixedSize(horizontal: true, vertical: false)
                                    .frame(height: 20)
                                    .popover(isPresented: $showNoNamePopover, arrowEdge: .trailing) {
                                        Text(i18n("enter_a_name"))
                                            .padding()
                                    }
                                    .popover(isPresented: $showDuplicatePopover, arrowEdge: .trailing) {
                                        // TODO: implement
                                        Text(i18n("enter_unique_name"))
                                            .padding()
                                    }
                                
                                createInstanceStar()
                            } else {
                                Text(instance.name)
                                    .font(.largeTitle)
                                    .frame(height: 20)
                                    .padding(.trailing, 8)
                                
                                createInstanceStar()
                            }
                            Spacer()
                        }
                        HStack {
                            if editingViewModel.inEditMode {
                                TextField("", text: $editingViewModel.synopsis, prompt: Text(instance.debugString))
                                    .fixedSize(horizontal: true, vertical: false)
                                    .font(.caption)
                                    .padding(.vertical, 6)
                                    .foregroundColor(.gray)
                                    .frame(height: 10)
                            } else {
                                Text(instance.synopsisOrVersion)
                                    .font(.caption)
                                    .padding(.vertical, 6)
                                    .foregroundColor(.gray)
                                    .frame(height: 10)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                    }
                }
                .sheet(isPresented: $showLogoSheet) {
                    createLogoSheet()
                }
                HStack {
                    if editingViewModel.inEditMode {
                        TextField("", text: $editingViewModel.notes, prompt: Text(i18n("notes")))
                            .font(.body)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .frame(minWidth: 50)
                            .padding(.leading, 3)
                    } else {
                        if instance.notes != nil {
                            Text(instance.notes!)
                                .font(.body)
                                .frame(minWidth: 50)
                                .padding(.leading, 3)
                        }
                    }
                    Spacer()
                }
                Spacer()
                createTabView()
            }
            .padding(.all, 6)
            .onAppear {
                launcherData.launchRequestedInstances.removeAll(where: { $0 == self.instance })
            }
            .sheet(isPresented: $showErrorSheet, content: createErrorSheet)
            .sheet(isPresented: $showPreLaunchSheet, content: createPrelaunchSheet)
            .sheet(isPresented: $showChooseAccountSheet, content: createChooseAccountSheet)
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
            .onAppear {
                launchedInstanceProcess = launcherData.launchedInstances[instance]
            }
        }
    }
    
    @ViewBuilder
    func createInstanceStar() -> some View {
        if instance.isStarred {
            Image(systemName: "star.fill")
                .resizable()
                .foregroundColor(starHovered ? .gray : .yellow)
                .onTapGesture {
                    withAnimation {
                        instance.isStarred = false
                    }
                }
                .frame(width: 16, height: 16)
            
        } else {
            Image(systemName: "star")
                .resizable()
                .foregroundColor(starHovered ? .yellow : .gray)
                .onTapGesture {
                    withAnimation {
                        instance.isStarred = true
                    }
                }
                .frame(width: 16, height: 16)
                .onHover { hoverValue in
                    withAnimation {
                        starHovered = hoverValue
                    }
                }
        }
    }
    
    @ViewBuilder
    func createTabView() -> some View {
        TabView {
            InstanceConsoleView(instance: instance, launchedInstanceProcess: $launchedInstanceProcess)
                .tabItem {
                    Label(i18n("console"), systemImage: "bolt")
                }
            InstanceRuntimeView(instance: instance)
                .tabItem {
                    Label(i18n("runtime"), systemImage: "bolt")
                }
//            TodoView()
//                .tabItem {
//                    Label(i18n("mods"), systemImage: "bolt")
//                }
//            TodoView()
//                .tabItem {
//                    Label(i18n("resource_packs"), systemImage: "bolt")
//                }
//            TodoView()
//                .tabItem {
//                    Label(i18n("worlds"), systemImage: "bolt")
//                }
//            TodoView()
//                .tabItem {
//                    Label(i18n("screenshots"), systemImage: "bolt")
//                }
//            TodoView()
//                .tabItem {
//                    Label(i18n("misc"), systemImage: "bolt")
//                }
        }.padding(.all, 4)
    }
    
    @ViewBuilder
    func createLogo() -> some View {
        let size = launcherData.globalPreferences.ui.compactInstanceLogo ? 64.0 : 128.0
        InstanceLogoView(instance: instance)
            .frame(width: size, height: size)
            .padding(.all, 20)
            .opacity(logoHovered ? 0.75 : 1)
            .onHover(perform: { value in
                withAnimation {
                    logoHovered = value
                }
            })
            .onTapGesture {
                showLogoSheet = true
            }
    }
    
    @ViewBuilder
    func createErrorSheet() -> some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        if let launchError = self.launchError {
                            Text(launchError.localizedDescription)
                            if let err = launchError.suppressed {
                                Text(err.localizedDescription)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                Button(i18n("close")) {
                    self.showErrorSheet = false
                }
                .keyboardShortcut(.cancelAction)
                .padding()
            }
        }
    }

    @ViewBuilder
    func createLogoSheet() -> some View {
        VStack {
            TabView {
                ImageLogoPickerView(instance: instance)
                    .tabItem {
                        Text(i18n("image"))
                    }
                SymbolLogoPickerView(instance: instance, logo: $instance.logo)
                    .tabItem {
                        Text(i18n("symbol"))
                    }
            }
            Button(i18n("done")) {
                withAnimation {
                    showLogoSheet = false
                }
            }
            .padding()
            .keyboardShortcut(.cancelAction)
        }
        .padding(.all, 15)
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
                if indeterminateProgress {
                    ProgressView()
                        .progressViewStyle(.linear)
                } else {
                    ProgressView(value: progress)
                }
                Button(i18n("abort")) {
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
        }
        // TODO: error handling
        .onAppear(perform: {
            onPrelaunchSheetAppear()
        })
        .padding(.all, 10)
    }
    
    func onPrelaunchSheetAppear() {
        self.indeterminateProgress = false
        self.downloadProgress.cancelled = false
        downloadMessage = i18n("downloading_libs")
        downloadSession = instance.downloadLibs(progress: downloadProgress) {
            downloadMessage = i18n("downloading_assets")
            downloadSession = instance.downloadAssets(progress: downloadProgress) {
                downloadMessage = i18n("extracting_natives")
                downloadProgress.callback = {
                    if !downloadProgress.cancelled {
                        self.indeterminateProgress = true
                        downloadMessage = i18n("authenticating_with_minecraft")
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
            return
        }
        self.showPreLaunchSheet = false
        self.showErrorSheet = true
        self.downloadProgress.cancelled = true
        self.launchError = error
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
