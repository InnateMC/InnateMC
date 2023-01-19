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
import InnateKit
import SwiftUI

struct InstanceRuntimeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var instance: Instance
    @State var valid: Bool = true
    
    var body: some View {
        VStack {
            Toggle("Override Global Java Settings", isOn: $instance.preferences.runtime.valid)
                .padding(.all, 4)
            Form {
                if valid {
                    Picker("Java", selection: $instance.preferences.runtime.defaultJava) {
                        PickableJavaVersion(installation: SavedJavaInstallation.systemDefault)
                        ForEach(viewModel.javaInstallations) {
                            PickableJavaVersion(installation: $0)
                        }
                    }
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: 550, minHeight: nil, maxHeight: nil)
                    TextField("Default Minimum Memory (MiB)", value: $instance.preferences.runtime.minMemory, formatter: NumberFormatter())
                        .frame(minWidth: nil, idealWidth: nil, maxWidth: 550, minHeight: nil, maxHeight: nil, alignment: .leading)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Default Maximum Memory (MiB)", value: $instance.preferences.runtime.maxMemory, formatter: NumberFormatter())
                        .frame(minWidth: nil, idealWidth: nil, maxWidth: 550, minHeight: nil, maxHeight: nil, alignment: .leading)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Default Java Arguments", text: $instance.preferences.runtime.javaArgs)
                        .frame(minWidth: nil, idealWidth: nil, maxWidth: 550, minHeight: nil, maxHeight: nil, alignment: .leading)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .onReceive(instance.preferences.runtime.$valid, perform: { value in
                valid = value
            })
            .onAppear {
                valid = instance.preferences.runtime.valid
            }
            .padding(.all, 16.0)
            Spacer()
        }
    }
}
