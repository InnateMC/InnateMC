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

struct InstanceView: View {
    @StateObject var instance: Instance
    @State var disabled: Bool = false
    @EnvironmentObject var launcherData: LauncherData
    @State var starHovered: Bool = false
    @State var logoHovered: Bool = false
    @State var showLogoSheet: Bool = false
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    @StateObject var editingViewModel = InstanceEditingViewModel()
    @State var showNoNamePopover: Bool = false
    @State var showDuplicatePopover: Bool = false
    
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
                                
                                Button(i18n("save")) {
                                    editingViewModel.commit(to: self.instance, showNoNamePopover: $showNoNamePopover, showDuplicateNamePopover: $showDuplicatePopover, data: self.launcherData)
                                }
                                .padding(.horizontal)
                                .buttonStyle(.borderless)
                            } else {
                                Text(instance.name)
                                    .font(.largeTitle)
                                    .frame(height: 20)
                                    .padding(.trailing, 8)
                                
                                createInstanceStar()
                                    
                                Button(i18n("edit")) {
                                    editingViewModel.start(from: self.instance)
                                }
                                .padding(.horizontal)
                                .buttonStyle(.borderless)
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
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstances = value
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
            InstanceLaunchView(instance: instance)
                .tabItem {
                    Label(i18n("launch"), systemImage: "bolt")
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
}
