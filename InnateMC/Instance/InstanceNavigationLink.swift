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
import InnateKit

struct InstanceNavigationLink: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var instance: Instance
    @State var starHovered: Bool = false
    @State var instanceStarred: Bool? = nil
    @State var compactList: Bool? = nil

    var body: some View {
        HStack {
            ZStack(alignment: .topTrailing) {
                if (compactList ?? viewModel.globalPreferences.ui.compactList) {
                    AsynchronousImage(instance.getLogoPath())
                        .frame(width: 32, height: 32)
                } else {
                    AsynchronousImage(instance.getLogoPath())
                        .frame(width: 48, height: 48)
                }
                ZStack {
                    if (instanceStarred ?? instance.isStarred) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 8, height: 8)
                    }
                }
                .onReceive(instance.$isStarred, perform: { value in
                    instanceStarred = value
                })
                .frame(width: 8, height: 8)
            }
            .onReceive(viewModel.globalPreferences.ui.$compactList) { value in
                compactList = value
            }
            VStack {
                HStack {
                    Text(instance.name)
                    Spacer()
                }
                HStack {
                    Text(instance.someDebugString)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            Spacer()
        }
        .contextMenu {
            Button(self.instance.isStarred ? "Unstar" : "Star") {
                instance.isStarred = !instance.isStarred
            }
        }
    }
}
