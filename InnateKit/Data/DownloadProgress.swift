//
// Created by Shrish Deshpande on 11/18/22.
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
        return current == total
    }

    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
}
