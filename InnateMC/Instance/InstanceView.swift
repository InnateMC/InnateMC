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
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    createLogo()
                    VStack {
                        HStack {
                            if editingViewModel.editMode {
                                TextField(i18n("name"), text: $editingViewModel.editName)
                                    .font(.largeTitle)
                                    .labelsHidden()
                                    .fixedSize(horizontal: true, vertical: false)
                                    .frame(height: 20)
                                
                                createInstanceStar()
                                
                                Button("Save") {
                                    editingViewModel.editMode = false
                                    // TODO: implement
                                }
                                .padding(.horizontal)
                                .buttonStyle(.borderless)
                            } else {
                                Text(instance.name)
                                    .font(.largeTitle)
                                    .frame(height: 20)
                                    .padding(.trailing, 8)
                                
                                createInstanceStar()
                                    
                                Button("Edit") {
                                    editingViewModel.editName = instance.name
                                    editingViewModel.editDebugString = instance.synopsis ?? ""
                                    editingViewModel.editMode = true
                                }
                                .padding(.horizontal)
                                .buttonStyle(.borderless)
                            }
                            Spacer()
                        }
                        HStack {
                            if editingViewModel.editMode {
                                TextField("", text: $editingViewModel.editDebugString, prompt: Text(instance.assetIndex.id))
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
                    if instance.description != nil {
                        Text(instance.description!)
                            .font(.body)
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
