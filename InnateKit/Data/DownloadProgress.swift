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

public class DownloadProgress: ObservableObject {
    @Published public var current: Float = 0
    @Published public var total: Float = 1
    
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

    public init(current: Float, total: Float) {
        self.current = current
        self.total = total
    }
    
    public static func completed() -> DownloadProgress {
        return DownloadProgress(current: 1, total: 1)
    }
    
    public func setFrom(_ other: DownloadProgress) {
        self.current = other.current
        self.total = other.total
    }
}
