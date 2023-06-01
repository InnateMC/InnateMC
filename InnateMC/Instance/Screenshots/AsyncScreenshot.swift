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
import Cocoa

struct AsyncScreenshot: View {
    @State private var nsImage: NSImage? = nil
    
    let screenshot: Screenshot
    @State var selected: Bool
    
    var body: some View {
        VStack {
            if let nsImage = nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
            }
        }
        .onAppear {
            DispatchQueue.global().async {
                let loadedImage: NSImage
                do {
                    let imageData = try Data(contentsOf: screenshot.path)
                    loadedImage = NSImage(data: imageData)!
                } catch {
                    ErrorTracker.instance.error(error: error, description: "Error loading screenshot")
                    return
                }
                DispatchQueue.main.async {
                    self.nsImage = loadedImage
                }
            }
        }
    }
}
