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
import CryptoKit

public class ParallelDownloader {
    fileprivate static let dispatchQueue = DispatchQueue(label: "Parallel Downloader")
    
    public static func download(_ tasks: [DownloadTask], progress: DownloadProgress, callback: (() -> Void)?) -> DownloadProgress {
        progress.current = 0
        progress.total = tasks.count
        let fm = FileManager.default
        
        @Sendable func dispatch(_ task: DownloadTask) {
            Task.init(priority: .medium, operation: {
                if fm.fileExists(atPath: task.filePath.path) {
                    let existing = try! Data(contentsOf: task.filePath)
                    if (!isSha1Valid(data: existing, expected: task.sha1)) {
                        print("Corrupted download found, redownloading")
                        try! fm.removeItem(at: task.filePath)
                        dispatch(task)
                    }
                    await progress.inc()
                } else {
                    let data = try! Data(contentsOf: task.url)
                    if (!isSha1Valid(data: data, expected: task.sha1)) {
                        print("Invalid hash while downloading, retrying")
                        dispatch(task)
                    } else {
                        let parent = task.filePath.deletingLastPathComponent()
                        if !fm.fileExists(atPath: parent.path) {
                            try! fm.createDirectory(at: parent, withIntermediateDirectories: true)
                        }
                        fm.createFile(atPath: task.filePath.path, contents: data)
                        await progress.inc()
                        if progress.isDone() {
                            if let callback = callback {
                                callback()
                            }
                        }
                    }
                }
            })
        }
        
        for task in tasks {
            dispatch(task)
        }
        
        return progress
    }
    
    internal static func isSha1Valid(data: Data, expected: String?) -> Bool {
        guard let expected = expected else {
            return true
        }
        let real = Insecure.SHA1.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
        return real == expected
    }
}

public class DownloadTask {
    public let url: URL
    public let filePath: URL
    public let sha1: String?
    
    public init(url: URL, filePath: URL, sha1: String?) {
        self.url = url
        self.filePath = filePath
        self.sha1 = sha1
    }
}
