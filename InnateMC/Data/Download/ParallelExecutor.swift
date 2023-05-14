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
import CryptoKit

public class ParallelExecutor {
    public static func run(_ tasks: [() -> Void], progress: TaskProgress) {
        progress.current = 0
        progress.total = tasks.count
        @Sendable func dispatch(_ task: @escaping () -> Void)  {
            let _: Task<(), Never> = Task.init(priority: .medium, operation: {
                task()
                await progress.inc()
            })
        }
        
        for task in tasks {
            dispatch(task)
        }
    }
    
    internal static func isSha1Valid(data: Data, expected: String?) -> Bool {
        guard let expected = expected else {
            return true
        }
        let real = Insecure.SHA1.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        return real == expected
    }
}
