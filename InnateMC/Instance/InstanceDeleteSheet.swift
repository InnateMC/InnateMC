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
// along with this program.  If not, see http://www.gnu.org/licenses/
//

import SwiftUI

struct InstanceDeleteSheet: View {
    @EnvironmentObject var launcherData: LauncherData
    @Binding var showDeleteSheet: Bool
    @Binding var selectedInstance: Instance?
    var instanceToDelete: Instance
    
    var body: some View {
        VStack(alignment: .center) {
            Text(i18n("are_you_sure_delete_instance"))
            HStack {
                Button(i18n("delete")) {
                    if let index = launcherData.instances.firstIndex(of: self.instanceToDelete) {
                        if let selectedInstance = self.selectedInstance {
                            if selectedInstance == instanceToDelete {
                                self.selectedInstance = nil
                            }
                        }
                        let instance = launcherData.instances.remove(at: index)
                        instance.delete()
                    }
                    showDeleteSheet = false
                }
                .padding()
                Button(i18n("cancel")) {
                    showDeleteSheet = false
                }
                .padding()
            }
        }
        .padding(.all, 20)
    }
}
