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
import InnateKit

@main
struct InnateMCApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .commands {
            CommandMenu("Edit") {
                Button("New Instance") {
                    // TODO: make this work
                }
                .keyboardShortcut("n") // TODO: make this work
            }
            InstanceListCommands()
        }
        Settings {
            PreferencesView()
                .environmentObject(viewModel)
                .frame(width: 800, height: 400)
                .onDisappear {
                    // this doesn't get called
                    viewModel.globalPreferences.save()
                }
        }
    }
}
