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

struct InstanceScreenshotsView: View {
    @StateObject var instance: Instance
    @State var selectedItem: Screenshot? = nil
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(instance.screenshots, id: \.self) { screenshot in
                        HStack {
                            ScreenshotView(screenshot: screenshot)
                                .padding(4)
                        }
                        .highPriorityGesture(TapGesture()
                            .onEnded({ i in
                                selectedItem = screenshot
                            }))
                        .background(screenshot == selectedItem ? Color.blue : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
            .background(Color(NSColor.textBackgroundColor))
            .padding()
            .frame(maxHeight: .infinity)
            
            if let selectedItem = selectedItem {
                Text(selectedItem.path.absoluteString)
            }
        }
    }
}
