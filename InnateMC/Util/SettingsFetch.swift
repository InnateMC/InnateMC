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

public func setting<T>(_ path: KeyPath<GlobalPreferences, T>) -> T {
    return LauncherData.currentInstanceUnsafe.globalPreferences[keyPath: path]
}

public func setting<T>(_ path: KeyPath<InstancePreferences, T>, for instance: Instance) -> T {
    return instance.preferences[keyPath: path]
}
