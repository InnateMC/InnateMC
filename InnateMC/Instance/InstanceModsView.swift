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

struct InstanceModsView: View {
    @StateObject var instance: Instance
    @State var selected: Set<Mod> = []
    @State var sortOrder: [KeyPathComparator<Mod>] = [ .init(\.meta.name, order: SortOrder.forward) ]
    
    var body: some View {
        Table(instance.mods, selection: $selected, sortOrder: $sortOrder) {
            TableColumn("Name", value: \.meta.name)
            TableColumn("File", value: \.path.lastPathComponent)
        }
        .onAppear {
            instance.loadModsAsync()
        }
    }
}
