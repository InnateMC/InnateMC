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
    @FocusState var selectedItem: Screenshot?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack {
            ScrollView {
                ZStack {
                    if instance.screenshots.count > 0 {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(instance.screenshots, id: \.self) { screenshot in
                                HStack {
                                    VStack {
                                        AsyncImage(url: screenshot.path, scale: 1) {
                                            $0.resizable().scaledToFit()
                                        } placeholder: {
                                            Image(systemName: "bolt")
                                                .resizable()
                                                .scaledToFit()
                                        }
                                        Text(screenshot.path.lastPathComponent)
                                            .font(.footnote)
                                    }
                                    .padding(2)
                                    .focusable()
                                    .focused($selectedItem, equals: screenshot)
                                    .onCopyCommand {
                                        return [NSItemProvider(contentsOf: screenshot.path)!]
                                    }
                                    .highPriorityGesture(TapGesture()
                                        .onEnded({ i in
                                            withAnimation(Animation.linear(duration: 0.1)) {
                                                selectedItem = screenshot
                                            }
                                        }))
                                }
                            }
                        }
                    } else {
                        Text(i18n("no_screenshots"))
                            .font(.largeTitle)
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
            .background(Color(NSColor.textBackgroundColor))
            .padding(.all, 7.0)
            
            HStack {
                ScreenshotShareButton(selectedItem: selectedItem)
                    .disabled(selectedItem == nil)
                Button(i18n("open_in_finder")) {
                    NSWorkspace.shared.selectFile(selectedItem?.path.path, inFileViewerRootedAtPath: instance.getScreenshotsFolder().path)
                }
            }
            .padding(.bottom, 8.0)
            .padding([.top, .leading, .trailing], 5.0)
        }
    }
}
