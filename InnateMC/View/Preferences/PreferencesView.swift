//
//  PreferencesView.swift
//  InnateMC
//
//  Created by Shrish Deshpande on 11/14/22.
//

import SwiftUI

struct PreferencesView: View {
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

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
