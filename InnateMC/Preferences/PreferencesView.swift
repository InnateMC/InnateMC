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
    @EnvironmentObject var launcherData: LauncherData

    var body: some View {
        TabView(selection: $launcherData.selectedPreferenceTab) {
            RuntimePreferencesView()
                .tabItem({
                    Label(i18n("runtime"), systemImage: "cup.and.saucer")
                })
                .tag(SelectedPreferenceTab.runtime)
            AccountsPreferencesView()
                .tabItem({
                    Label(i18n("accounts"), systemImage: "person.circle")
                })
                .tag(SelectedPreferenceTab.accounts)
//            GamePreferencesView()
//                .tabItem({
//                    Label(i18n("game"), systemImage: "gamecontroller")
//                })
//                .tag(SelectedPreferenceTab.game)
            UiPreferencesView()
                .tabItem({
                    Label(i18n("user_interface"), systemImage: "paintbrush.pointed")
                })
                .tag(SelectedPreferenceTab.ui)
//            ConsolePreferencesView()
//                .tabItem({
//                    Label(i18n("console"), systemImage: "terminal")
//                })
//                .tag(SelectedPreferenceTab.console)
//            MiscPreferencesView()
//                .tabItem({
//                    Label(i18n("misc"), systemImage: "slider.horizontal.3")
//                })
//                .tag(SelectedPreferenceTab.misc)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.launcherData.initializePreferenceListenerIfNot()
            }
        }
    }
}
