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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

struct InstanceConsoleView: View {
    var instance: Instance
    @Binding var launchedInstanceProcess: InstanceProcess?
    @EnvironmentObject var launcherData: LauncherData
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    @State var logMessages: [String] = []
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(self.logMessages, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                                .id(message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .id(self.logMessages)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                )
                .padding(.all, 7.0)
                if self.launchedInstanceProcess != nil {
                    ZStack {
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(self.logMessages.last, anchor: .bottom)
                        }
                        self.logMessages = self.launchedInstanceProcess!.logMessages
                    }
                    .onReceive(self.launchedInstanceProcess!.$logMessages) {
                        self.logMessages = $0
                    }
                }
            }
            
            Spacer()
        }
    }
}
