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

struct ScreenshotView: View {
    var screenshot: Screenshot
    @State var sheetShown: Bool = false
    
    var body: some View {
        VStack {
            AsyncImage(url: screenshot.path, scale: 1) {
                $0.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "bolt")
                    .resizable()
                    .scaledToFit()
            }
            .onTapGesture(count: 2) {
                withAnimation {
                    self.sheetShown = true
                }
            }
            Text(screenshot.path.lastPathComponent)
                .font(.footnote)
        }
        .padding()
        .sheet(isPresented: $sheetShown) {
            VStack {
                AsyncImage(url: screenshot.path, scale: 1)
                Text(screenshot.path.lastPathComponent)
                Button(i18n("cancel")) {
                    self.sheetShown = false
                }
                .padding([.top])
                .keyboardShortcut(.cancelAction)
            }
            .padding()
        }
        .eraseToAnyView()
    }

    #if DEBUG
    @ObservedObject var iO = injectionObserver
    #endif
}
