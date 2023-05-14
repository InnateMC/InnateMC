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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import SwiftUI

open class TaskProgress: ObservableObject {
    @Published public var current: Int = 0
    @Published public var total: Int = 1
    public var callback: (() -> Void)? = nil
    public var cancelled = false
    
    public init() {
    }
    
    public func fraction() -> Double {
        return Double(current) / Double(total)
    }
    
    public func percentString() -> String {
        return String(format: "%.2f", fraction() * 100) + "%"
    }
    
    @MainActor
    open func inc() {
        self.current += 1
        if (self.current == self.total) {
            callback?()
        }
    }
    
    public func intPercent() -> Int {
        return Int((fraction() * 100).rounded())
    }
    
    public func isDone() -> Bool {
        return Int(current) >= Int(total)
    }
    
    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
    
    public static func completed() -> TaskProgress {
        return TaskProgress(current: 1, total: 1)
    }
    
    public func setFrom(_ other: TaskProgress) {
        self.current = other.current
        self.total = other.total
    }
}
