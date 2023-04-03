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
    @State var instance: Instance
    @State var disabled: Bool = false
    @EnvironmentObject var launcherData: LauncherData
    @State var instanceStarred: Bool? = nil
    @State var leftAlignedInstanceHeading: Bool? = nil
    private var leftAlignedInstanceHeadingNotNull: Bool {
        get {
            leftAlignedInstanceHeading ?? launcherData.globalPreferences.ui.leftAlignedInstanceHeading
        }
    }
    @State var starHovered: Bool = false
    @State var logoHovered: Bool = false
    @State var showLogoSheet: Bool = false
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    InstanceLogoView(instance: instance)
                        .frame(width: 128, height: 128)
                        .padding(.all, 20)
                        .opacity(logoHovered ? 0.5 : 1)
                        .onHover(perform: { value in
                            withAnimation {
                                logoHovered = value
                            }
                        })
                        .onTapGesture {
                            showLogoSheet = true
                        }
                    VStack {
                        HStack {
                            if !leftAlignedInstanceHeadingNotNull {
                                Spacer()
                            }
                            Text(instance.name)
                                .font(.largeTitle)
                            if instanceStarred ?? instance.isStarred {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .foregroundColor(starHovered ? .gray : .yellow)
                                    .onTapGesture {
                                        instance.isStarred = false
                                    }
                                    .frame(width: 16, height: 16)

                            } else {
                                Image(systemName: "star")
                                    .resizable()
                                    .foregroundColor(starHovered ? .yellow : .gray)
                                    .onTapGesture {
                                        instance.isStarred = true
                                    }
                                    .frame(width: 16, height: 16)
                                    .onHover { hoverValue in
                                        withAnimation {
                                            starHovered = hoverValue
                                        }
                                    }
                            }
                            Spacer()
                        }
                        HStack {
                            if !leftAlignedInstanceHeadingNotNull {
                                Spacer()
                            }
                            Text(instance.someDebugString)
                                .font(.caption)
                                .padding(.all, 6)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                .onReceive(instance.$isStarred) { value in
                    withAnimation {
                        instanceStarred = value
                    }
                }
                .sheet(isPresented: $showLogoSheet) {
                    VStack {
                        TabView {
                            ImageLogoPickerView(instance: instance)
                                .tabItem {
                                    Text("Image")
                                }
                            SymbolLogoPickerView(instance: instance, logo: $instance.logo)
                                .tabItem {
                                    Text("Symbol")
                                }
                        }
                        Button("Done") {
                            withAnimation {
                                showLogoSheet = false
                            }
                        }
                        .padding()
                        .keyboardShortcut(.cancelAction)
                    }
                    .regularMaterialBackground()
                    .padding(.all, 15)
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
                    InstanceLaunchView(instance: instance)
                        .tabItem {
                            Label("Launch", systemImage: "bolt")
                        }
                    InstanceRuntimeView(instance: $instance)
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
            .padding(.all, 6)
            .onReceive(launcherData.globalPreferences.ui.$leftAlignedInstanceHeading) { value in
                leftAlignedInstanceHeading = value
            }
            .onReceive(launcherData.$launchedInstances) { value in
                launchedInstances = value
            }
        }
    }
}

struct LaunchButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, 2)
            .foregroundColor(.white)
            .background(Color(red: 0, green: 0.5, blue: 1.0))
            .clipShape(Capsule())
    }
}

struct KillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, 2)
            .foregroundColor(.white)
            .background(Color(red: 1.0, green: 0.2, blue: 0.2))
            .clipShape(Capsule())
    }
}
