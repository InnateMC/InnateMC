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

struct RuntimePreferencesView: View {
    var body: some View {
            HStack {
                Form {
                    Toggle("Send read receipts", isOn: .constant(false))

                    TextField("Pls work", text: .constant("1826"))
                    
                    Picker("Profile Image Size:", selection: .constant("lg")) {
                        Text("Large").tag("lg")
                        Text("Medium").tag("md")
                        Text("Small").tag("sm")
                    }
                    .pickerStyle(.inline)

                    Button("Clear Image Cache") {}
                }
                
            }
            .padding(.all, 16.0)
    }
}

struct RuntimePreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        RuntimePreferencesView()
    }
}
