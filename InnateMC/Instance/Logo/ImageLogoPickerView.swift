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

struct ImageLogoPickerView: View {
    @State var shouldShowFileImporter: Bool = false
    @State var showImagePreview: Bool = false
    var instance: Instance
    
    var body: some View {
        VStack {
            if showImagePreview {
                AsyncImage(url: instance.getLogoPath(), content: {
                    $0.resizable().scaledToFit()
                }) {
                    Image(systemName: "tray.circle").resizable()
                }
            }
            Button(i18n("open")) {
                shouldShowFileImporter = true
            }
            .padding(.all, 50)
            .fileImporter(isPresented: $shouldShowFileImporter, allowedContentTypes: [.png]) { result in
                let url: URL
                do {
                    url = try result.get()
                } catch {
                    return
                }
                // TODO: error handling
                let fm = FileManager.default
                let logoPath = instance.getLogoPath()
                if fm.fileExists(atPath: logoPath.path) {
                    try! fm.removeItem(at: logoPath)
                }
                try! fm.copyItem(at: url, to: logoPath)
                DispatchQueue.main.async {
                    instance.logo = InstanceLogo(logoType: .file, string: "")
                    DispatchQueue.global().async {
                        try! instance.save()
                    }
                    showImagePreview = true
                }
            }
        }
    }
}
