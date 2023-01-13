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

struct PreferencesView: View {
    @EnvironmentObject var viewModel: ViewModel

    var body: some View {
        TabView {
            RuntimePreferencesView()
                .tabItem({
                    Label("Runtime", systemImage: "bolt")
                })
            AccountsPreferencesView()
                .tabItem({
                    Label("Accounts", systemImage: "person.circle")
                })
            GamePreferencesView()
                .tabItem({
                    Label("Game", systemImage: "gamecontroller")
                })
            UiPreferencesView()
                .tabItem({
                    Label("UI", systemImage: "tray.2")
                })
            ConsolePreferencesView()
                .tabItem({
                    Label("Console", systemImage: "terminal")
                })
            MiscPreferencesView()
                .tabItem({
                    Label("Misc", systemImage: "drop")
                })
        }
    }
}
