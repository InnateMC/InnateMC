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
            TodoView()
                .tabItem({
                    Label("Runtime", systemImage: "bolt")
                })
            TodoView()
                .tabItem({
                    Label("Accounts", systemImage: "person.circle")
                })
            TodoView()
                .tabItem({
                    Label("Game", systemImage: "gamecontroller")
                })
            TodoView()
                .tabItem({
                    Label("Console", systemImage: "terminal")
                })
            TodoView()
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
