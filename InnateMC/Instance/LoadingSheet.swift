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
import Cocoa
import InnateKit

struct LoadingSheet: View {
    @EnvironmentObject var viewModel: ViewModel
    var instance: Instance
    
    var body: some View {
        VStack {
//            Text(viewModel.currentDownloadStatus)
//                .font(.title2)
//            GeometryReader { geometry in
//                ZStack(alignment: .leading) {
//                    Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
//                        .opacity(0.3)
//                        .foregroundColor(Color(NSColor.darkGray))
//
//                    Rectangle().frame(width: min(CGFloat(self.viewModel.currentDownloadProgress.current / self.viewModel.currentDownloadProgress.total) * geometry.size.width, geometry.size.width), height: geometry.size.height)
//                        .foregroundColor(Color(NSColor.systemBlue))
//                        .animation(.linear)
//                }.cornerRadius(45.0)
//            }
//            ProgressView("", value: self.viewModel.currentDownloadProgress.current, total: self.viewModel.currentDownloadProgress.total)
            
            LoadingSheetViewControllerRepresentable(instance: instance)
        }.frame(width: 300, height: 79)
    }
}
