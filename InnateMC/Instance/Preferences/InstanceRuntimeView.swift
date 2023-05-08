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

import Foundation
import SwiftUI

struct InstanceRuntimeView: View {
    @EnvironmentObject var launcherData: LauncherData
    @StateObject var instance: Instance
    @State var valid: Bool = false
    @State var selectedJava: SavedJavaInstallation = SavedJavaInstallation.systemDefault
    
    var body: some View {
        VStack {
            Form {
                Toggle(isOn: $instance.preferences.runtime.valid, label: { Text(i18n("Override default runtime settings")) })
                    .padding(.bottom, 5)
                Picker(i18n("java"), selection: $selectedJava) {
                    PickableJavaVersion(installation: SavedJavaInstallation.systemDefault)
                    ForEach(launcherData.javaInstallations) {
                        PickableJavaVersion(installation: $0)
                    }
                }
                .disabled(!valid)
                TextField(i18n("default_min_mem"), value: $instance.preferences.runtime.minMemory, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!valid)
                TextField(i18n("default_max_mem"), value: $instance.preferences.runtime.maxMemory, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!valid)
                TextField(i18n("default_java_args"), text: $instance.preferences.runtime.javaArgs)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!valid)
            }
            .padding(.all, 16.0)
            Spacer()
        }
        .onAppear {
            valid = instance.preferences.runtime.valid
            selectedJava = instance.preferences.runtime.defaultJava
        }
        .onChange(of: selectedJava, perform: { newValue in
            instance.preferences.runtime.defaultJava = newValue
        })
        .onReceive(instance.preferences.runtime.$valid) {
            if !$0 && valid {
                instance.preferences.runtime = .init(launcherData.globalPreferences.runtime).invalidate()
                selectedJava = launcherData.globalPreferences.runtime.defaultJava
            }
            valid = $0
        }
    }
}
