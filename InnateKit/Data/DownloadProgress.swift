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

public class DownloadProgress {
    public var current: Int = 0
    public var total: Int = 1
    
    public init() {
    }
    
    public func fraction() -> Double {
        return Double(current) / Double(total)
    }

    public func percentString() -> String {
        return String(format: "%.2f", fraction() * 100) + "%"
    }

    public func intPercent() -> Int {
        return Int((fraction() * 100).rounded())
    }
    
    public func isDone() -> Bool {
        return current >= total
    }

    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
    
    public static func completed() -> DownloadProgress {
        return DownloadProgress(current: 1, total: 1)
    }
}
