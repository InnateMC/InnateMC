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

import Foundation
import SwiftUI

enum TrackedErrorType {
    case nonEssentialError
    case error
    
    @ViewBuilder
    var icon: some View {
        switch(self) {
        case .nonEssentialError:
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.yellow)
                .frame(width: 48, height: 48)
        case .error:
            ZStack {
                Image(systemName: "square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.red)
                    .frame(width: 48, height: 48)
            }
            .frame(width: 48, height: 48)
        }
    }
}
