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

struct InstanceTitleView: View {
    @StateObject var editingViewModel: InstanceEditingViewModel
    @StateObject var instance: Instance
    @Binding var showNoNamePopover: Bool
    @Binding var showDuplicatePopover: Bool
    @Binding var starHovered: Bool
    
    var body: some View {
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
            
            InteractiveStarView(instance: self.instance, starHovered: $starHovered)
        } else {
            Text(instance.name)
                .font(.largeTitle)
                .frame(height: 20)
                .padding(.trailing, 8)
            
            InteractiveStarView(instance: self.instance, starHovered: $starHovered)
        }
    }
}
