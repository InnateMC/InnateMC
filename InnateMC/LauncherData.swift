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

import Foundation
import AppKit
import Combine

public class LauncherData: ObservableObject {
    private var currentInstance: LauncherData? = nil
    internal var currentInstanceUnsafe: LauncherData { currentInstance! }
    @Published var instances: [Instance] = Instance.loadInstancesThrow()
    @Published var globalPreferences: GlobalPreferences = GlobalPreferences()
    @Published var javaInstallations: [SavedJavaInstallation] = []
    @Published var launchedInstances: [Instance: InstanceProcess] = [:]
//    @Published var selectedInstance: Instance? = nil
    @Published var newInstanceRequested: Bool = false
    private var initializedPreferenceListener: Bool = false
    
    public func initializePreferenceListenerIfNot() {
        if (initializedPreferenceListener) {
            return
        }
        initializedPreferenceListener = true
        let preferencesWindow = NSApp.keyWindow
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: preferencesWindow, queue: .main) { notification in
            DispatchQueue.global().async {
                self.globalPreferences.save()
            }
        }
    }
    
//    private var cancellables = Set<AnyCancellable>()
    
    init() {
        DispatchQueue.global().async {
            let globalPreferences = GlobalPreferences.load()
            DispatchQueue.main.async {
                self.globalPreferences = globalPreferences
            }
        }
        DispatchQueue.global().async {
            let javaInstallations = try! SavedJavaInstallation.load()
            DispatchQueue.main.async {
                self.javaInstallations = javaInstallations
            }
        }
        currentInstance = self
//        $selectedInstance.sink { [weak self] value in
//            guard self != nil else { return }
//            if let value = value {
//                print("Selected: \(value.name)")
//            }
//        }
//        .store(in: &cancellables)
    }
}
