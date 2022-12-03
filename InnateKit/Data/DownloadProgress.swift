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
import Atomics

open class DownloadProgress: ObservableObject {
    public var current = ManagedAtomic<Int>(0)
    public var total: Int = 1

    public init() {
    }

    public func fraction() -> Double {
        return Double(current.load(ordering: .relaxed)) / Double(total)
    }

    public func percentString() -> String {
        return String(format: "%.2f", fraction() * 100) + "%"
    }
    
    open func inc() {
        self.current.wrappingIncrement(by: 1, ordering: .relaxed)
    }

    public func intPercent() -> Int {
        return Int((fraction() * 100).rounded())
    }
    
    public func isDone() -> Bool {
        return current.load(ordering: .relaxed) >= Int(total)
    }

    public init(current: Int, total: Int) {
        self.current = ManagedAtomic<Int>(current)
        self.total = total
    }

    public static func completed() -> DownloadProgress {
        return DownloadProgress(current: 1, total: 1)
    }
    
    public func setFrom(_ other: DownloadProgress) {
        self.current = ManagedAtomic<Int>(other.current.load(ordering: .relaxed))
        self.total = other.total
    }
}
