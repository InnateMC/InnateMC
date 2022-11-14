//
//  InnateMCApp.swift
//  InnateMC
//
//  Created by Shrish Deshpande on 11/14/22.
//

import SwiftUI

@main
struct InnateMCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            PreferencesView()
                .frame(width: 600, height: 400)
        }
    }
}
