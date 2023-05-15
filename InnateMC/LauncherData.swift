//
// Copyright © 2022 InnateMC and contributors
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
    private static var currentInstance: LauncherData? = nil
    public static var instance: LauncherData { currentInstance! }
    @Published var instances: [Instance] = Instance.loadInstancesThrow()
    @Published var globalPreferences: GlobalPreferences = GlobalPreferences()
    @Published var javaInstallations: [SavedJavaInstallation] = []
    @Published var launchedInstances: [Instance: InstanceProcess] = [:]
    @Published var newInstanceRequested: Bool = false
    @Published var instanceLaunchRequested: Bool = false
    @Published var accountManager: AccountManager = AccountManager()
    @Published var selectedPreferenceTab: SelectedPreferenceTab = .ui
    @Published var versionManifest: [PartialVersion] = []
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
    
    init() {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let manifest = try VersionManifest.getOrCreate()
                DispatchQueue.main.async {
                    self.versionManifest = manifest
                }
            } catch {
                NSLog("Error downloading version manifest - Instance creation support is limited")
            }
        }
        DispatchQueue.global().async {
            do {
                let globalPreferences = try GlobalPreferences.load()
                DispatchQueue.main.async {
                    self.globalPreferences = globalPreferences
                }
            } catch {
                NSLog("Error loading preferences - Using default values")
            }
        }
        DispatchQueue.global().async {
            do {
                let javaInstallations = try SavedJavaInstallation.load()
                DispatchQueue.main.async {
                    self.javaInstallations = javaInstallations
                }
            } catch {
                NSLog("Error loading saved java versions - Java runtime support is limited")
            }
        }
        DispatchQueue.global().async {
            do {
                let accountManager = try AccountManager.load()
                DispatchQueue.main.async {
                    self.accountManager = accountManager
                }
                accountManager.setupForAuth()
            } catch {
                NSLog("Error loading account manager - Account switching support is limited")
            }
        }
        LauncherData.currentInstance = self
    }
}

// TODO: move
public enum SelectedPreferenceTab: Int, Hashable, Codable {
    case runtime = 0
    case accounts = 1
    case game = 2
    case ui = 3
    case console = 4
    case misc = 5
}
