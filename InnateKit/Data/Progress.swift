//
// Created by Shrish Deshpande on 11/18/22.
//

import Foundation

public struct Progress {
    public var current: Int
    public var total: Int
    public var fraction: Double {
        return Double(current) / Double(total)
    }
    public var percentString: String {
        return String(format: "%.2f", fraction * 100) + "%"
    }
}
