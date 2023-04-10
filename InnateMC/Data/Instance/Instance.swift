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

import Foundation
import SwiftUI
import Combine

public class Instance: Identifiable, Hashable, InstanceData, ObservableObject {
    public var name: String // TODO: make published
    public var assetIndex: PartialAssetIndex
    public var libraries: [Library]
    public var mainClass: String
    public var minecraftJar: MinecraftJar
    @Published public var isStarred: Bool
    @Published public var logo: InstanceLogo
    @Published public var description: String?
    public var debugString: String? // TODO: what even is this?
    public var someDebugString: String { // TODO: rename this
        get { return debugString ?? assetIndex.id }
        set(newValue) { self.debugString = newValue }
    }
    public var lastPlayed: Date?
    public var preferences = InstancePreferences()
    public var startOnFirstThread: Bool = false
    public var gameArguments: [String]
    
    public init(name: String,
                assetIndex: PartialAssetIndex,
                libraries: [Library],
                mainClass: String,
                minecraftJar: MinecraftJar,
                isStarred: Bool,
                logo: InstanceLogo,
                description: String?,
                debugString: String?,
                gameArguments: [String]
    ) {
        self.name = name
        self.assetIndex = assetIndex
        self.libraries = libraries
        self.mainClass = mainClass
        self.minecraftJar = minecraftJar
        self.isStarred = isStarred
        self.logo = logo
        self.description = description
        self.debugString = debugString
        self.gameArguments = gameArguments
    }
    
    public func setPreferences(_ prefs: InstancePreferences) {
        self.preferences = prefs
    }
    
    public func setStartOnFirstThread() {
        self.startOnFirstThread = true
    }
    
    public func getPath() -> URL {
        return FileHandler.instancesFolder.appendingPathComponent(self.name + ".innate", isDirectory: true)
    }
    
    public func getGamePath() -> URL {
        return getPath().appendingPathComponent("minecraft", isDirectory: true)
    }
    
    public func getNativesPath() -> URL {
        return getPath().appendingPathComponent("natives", isDirectory: true)
    }
    
    public func getMcJarPath() -> URL {
        return getPath().appendingPathComponent("minecraft.jar")
    }
    
    public func getLogoPath() -> URL {
        return getPath().appendingPathComponent("logo.png")
    }
    
    public func matchesSearchTerm(_ term: String) -> Bool {
        if term.isEmpty {
            return true
        }
        return self.name.localizedCaseInsensitiveContains(term) || self.someDebugString.localizedCaseInsensitiveContains(term)
    }
    
    public static func == (lhs: Instance, rhs: Instance) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.description)
        hasher.combine(self.someDebugString)
    }
}
