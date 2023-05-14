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

import Foundation
import SwiftUI

public class InstanceEditingViewModel: ObservableObject {
    @Published var inEditMode: Bool = false
    @Published var name: String = ""
    @Published var synopsis: String = ""
    @Published var notes: String = ""
    
    public func start(from instance: Instance) {
        self.name = instance.name
        self.synopsis = instance.synopsis ?? ""
        self.notes = instance.notes ?? ""
        self.inEditMode = true
    }
    
    public func commit(to instance: Instance, showNoNamePopover: Binding<Bool>, showDuplicateNamePopover: Binding<Bool>, data launcherData: LauncherData) {
        showNoNamePopover.wrappedValue = false
        showDuplicateNamePopover.wrappedValue = false
        self.inEditMode = false
        instance.notes = self.notes == "" ? nil : self.notes
        instance.synopsis = self.synopsis == "" ? nil : self.synopsis
        if self.name != instance.name && !self.name.isEmpty {
            let trimmedName = self.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                showNoNamePopover.wrappedValue = true
                return
            }
            if launcherData.instances.map({ $0.name }).contains(where: { $0.lowercased() == trimmedName.lowercased()}) {
                showDuplicateNamePopover.wrappedValue = true
                return
            }
            instance.renameAsync(to: self.name)
        }
    }
}
