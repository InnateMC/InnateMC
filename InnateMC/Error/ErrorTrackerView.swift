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

struct ErrorTrackerView: View {
    @StateObject var errorTracker: ErrorTracker
    @State var selection: ErrorTrackerEntry? = nil
    
    @ViewBuilder
    var body: some View {
        List(selection: $selection) {
            ForEach(errorTracker.errors, id: \.counter) { entry in
                HStack {
                    entry.type.icon
                    
                    VStack {
                        HStack {
                            Text(entry.description)
                                .padding(.bottom, 2)
                            Spacer()
                        }
                        if let error = entry.error {
                            HStack {
                                Text(error.localizedDescription)
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                }
                .padding(2)
            }
        }
    }
}

struct ErrorTrackerView_Previews: PreviewProvider {
    static let errorTracker: ErrorTracker = {
        let tracker = ErrorTracker()
        tracker.nonEssentialError(description: "Something happened!")
        tracker.error(error: LaunchError.errorDownloading(error: nil), description: "Something bad happened!")
        tracker.nonEssentialError(description: "Something happened but it wasn't that bad")
        return tracker
    }()
    
    static var previews: some View {
        ErrorTrackerView(errorTracker: errorTracker)
    }
}
