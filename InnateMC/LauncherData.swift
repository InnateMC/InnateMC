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
    @Published var instances: [Instance] = []
    @Published var globalPreferences: GlobalPreferences = GlobalPreferences()
    @Published var javaInstallations: [SavedJavaInstallation] = []
    @Published var launchedInstances: [Instance: InstanceProcess] = [:]
    @Published var newInstanceRequested: Bool = false
    @Published var accountManager: AccountManager = AccountManager()
    @Published var selectedPreferenceTab: SelectedPreferenceTab = .ui
    @Published var versionManifest: [PartialVersion] = []
    @Published var launchRequestedInstances: [Instance] = []
    @Published var editModeInstances: [Instance] = []
    @Published var killRequestedInstances: [Instance] = []
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
                logger.debug("Saved preferences")
            }
        }
        logger.info("Initialized preferences save handler")
    }
    
    init() {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let instances = try Instance.loadInstances()
                DispatchQueue.main.async {
                    self.instances = instances
                }
                logger.info("Loaded \(instances.count) instances")
            } catch {
                logger.error("Could not load instances", error: error)
            }
        }
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let manifest = try VersionManifest.getOrCreate()
                DispatchQueue.main.async {
                    self.versionManifest = manifest
                }
                logger.info("Downloaded version manifest")
            } catch {
                logger.error("Could not download version manifest", error: error)
                logger.error("Instance creation support is limited")
            }
        }
        DispatchQueue.global().async {
            do {
                let globalPreferences = try GlobalPreferences.load()
                DispatchQueue.main.async {
                    self.globalPreferences = globalPreferences
                }
                logger.info("Loaded preferences")
            } catch {
                logger.error("Could not load preferences", error: error)
                logger.error("Using default values")
            }
        }
        DispatchQueue.global().async {
            do {
                let javaInstallations = try SavedJavaInstallation.load()
                DispatchQueue.main.async {
                    self.javaInstallations = javaInstallations
                }
                logger.info("Loaded saved java runtimes")
            } catch {
                logger.error("Could not load saved java runtimes", error: error)
                logger.error("Instance launch support is limited")
            }
        }
        DispatchQueue.global().async {
            do {
                let accountManager = try AccountManager.load()
                DispatchQueue.main.async {
                    self.accountManager = accountManager
                }
                accountManager.setupForAuth()
                logger.info("Initialized account manager")
            } catch {
                logger.error("Could not load account manager", error: error)
                logger.error("Accounts support is limited")
            }
        }
        LauncherData.currentInstance = self
        logger.debug("Initialized launcher data")
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
