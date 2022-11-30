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

struct UiPreferencesView: View {
    @AppStorage("innatemc.compactList") private var compactList: Bool = false
    @AppStorage("innatemc.rightAlignedInstanceHeading") private var rightAlignedInstanceHeading: Bool = false

    var body: some View {
        Form {
            Toggle("Compact Instance List", isOn: $compactList)
            Toggle("Right-Aligned Instance Heading", isOn: $rightAlignedInstanceHeading)
        }
        .padding(.all, 16.0)
    }
}

struct UiPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        UiPreferencesView()
    }
}
