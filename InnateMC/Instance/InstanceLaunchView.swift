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

struct InstanceLaunchView: View {
    var instance: Instance
    @State var showingInstallSheet: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    print(instance.getPath().absoluteString)
                }, label: {
                    Text("Launch")
                        .font(.title2)
                })
            }
        }
        .sheet(isPresented: $showingInstallSheet) {
            ZStack {
            }
            .padding(.all, 10)
        }
    }
}
