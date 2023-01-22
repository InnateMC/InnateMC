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

public class ViewModel: ObservableObject {
    @Published var instances: [Instance] = Instance.loadInstancesThrow()
    @Published var showNewInstanceSheet: Bool = false
    @Published var globalPreferences: GlobalPreferences = GlobalPreferences()
    @Published var javaInstallations: [SavedJavaInstallation] = []
    @Published var selectedInstance: Instance?
    
    init() {
        DispatchQueue.global().async {
            let globalPreferences = GlobalPreferences.load()
            DispatchQueue.main.async {
                self.globalPreferences = globalPreferences
            }
        }
        DispatchQueue.global().async {
            let javaInstallations = try! SavedJavaInstallation.load()
            DispatchQueue.main.async {
                self.javaInstallations = javaInstallations
            }
        }
    }
}
