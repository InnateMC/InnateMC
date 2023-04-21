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

struct AddOfflineAccountView: View {
    @State var username = ""
    @State var showBlankPopover = false
    @Binding var showSheet: Bool
    @State var onCommit: (String) -> Void
    
    var body: some View {
        VStack {
            Form {
                TextField(i18n("username"), text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .popover(isPresented: $showBlankPopover, arrowEdge: .bottom) {
                        Text(i18n("enter_a_username"))
                            .padding()
                    }
                    .padding()
            }
            HStack {
                if !isValidMinecraftUsername(self.username) {
                    Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        Text(i18n("invalid_username"))
                }
                Spacer()
                Button(i18n("cancel")) {
                    showSheet = false
                }
                .keyboardShortcut(.cancelAction)
                Button(i18n("done")) {
                    if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showBlankPopover = true
                    } else {
                        onCommit(self.username)
                        showSheet = false
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(maxWidth: 350)
    }
    
    private func isValidMinecraftUsername(_ username: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        let disallowedWords = ["minecraft", "mojang", "admin", "administrator"]
        
        if username.count < 3 || username.count > 16 {
            return false
        }
        
        if !username.allSatisfy({ allowedCharacters.contains(UnicodeScalar(String($0))!) }) {
            return false
        }
        
        let lowercaseUsername = username.lowercased()
        if disallowedWords.contains(where: { lowercaseUsername.contains($0) }) {
            return false
        }
        
        return true
    }
}
