//
//  InnateMCApp.swift
//  InnateMC
//
//  Created by Shrish Deshpande on 11/14/22.
//

import SwiftUI

@main
struct InnateMCApp: App {
    init() {
        InnateMCData.instances.append(Instance(name: "1.19.2", id: "1.19.2", imageSystemName: ""))
        InnateMCData.instances.append(Instance(name: "1.17.1", id: "1.17.1", imageSystemName: ""))
        InnateMCData.instances.append(Instance(name: "1.12.2", id: "1.12.2", imageSystemName: ""))
    }
    
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
