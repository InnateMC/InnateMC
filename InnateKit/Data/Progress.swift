//
// Created by Shrish Deshpande on 11/18/22.
//

import Foundation

struct Progress {
    var current: Int
    var total: Int
    var fraction: Double {
        return Double(current) / Double(total)
    }
    var percentString: String {
        return String(format: "%.2f", fraction * 100) + "%"
    }
}
