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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Foundation
import CryptoKit

public struct ParallelDownloader {
    public static func download(_ tasks: [DownloadTask], progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (LaunchError) -> Void) -> URLSession {
        progress.current = 0
        progress.total = tasks.count
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 180
        config.timeoutIntervalForRequest = 180
        
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let downloadGroup = DispatchGroup()
        
        for (_, task) in tasks.enumerated() {
            downloadGroup.enter()
            
            let destinationUrl = task.filePath
            
            DispatchQueue.global(qos: .utility).async {
                let fileExists = FileManager.default.fileExists(atPath: destinationUrl.path)
                
                if fileExists {
                    let isHashValid = checkHash(path: destinationUrl, expected: task.sha1)
                    if isHashValid {
                        DispatchQueue.main.async {
                            progress.inc()
                            downloadGroup.leave()
                        }
                        return
                    }
                }
                
                let taskUrl = task.sourceUrl
                let downloadTask = session.downloadTask(with: taskUrl) { (tempUrl, response, error) in
                    if error != nil {
                        session.invalidateAndCancel()
                        DispatchQueue.main.async {
                            onError(LaunchError.errorDownloading(error: error))
                        }
                        downloadGroup.leave()
                        return
                    } else if let tempUrl = tempUrl {
                        do {
                            // Verify sha hash
                            if !checkHash(path: tempUrl, expected: task.sha1) {
                                throw LaunchError.invalidShaHash(error: nil)
                            }
                            let fileManager = FileManager.default
                            if !fileExists {
                                try fileManager.createDirectory(at: destinationUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
                                if !FileManager.default.fileExists(atPath: destinationUrl.path) {
                                    try fileManager.moveItem(at: tempUrl, to: destinationUrl)
                                }
                            }
                            DispatchQueue.main.async {
                                progress.inc()
                            }
                        } catch {
                            session.invalidateAndCancel()
                            if let error = error as? LaunchError {
                                DispatchQueue.main.async {
                                    onError(error)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    onError(LaunchError.unknownError(error: error))
                                }
                            }
                        }
                    }
                    downloadGroup.leave()
                }
                
                downloadTask.resume()
            }
        }
        
        downloadGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                onFinish()
            }
        }
        
        return session
    }
    
    private static func calculateSHA1Hash(for filePath: URL) -> String? {
        do {
            let fileData = try Data(contentsOf: filePath)
            let digest = Insecure.SHA1.hash(data: fileData)
            return digest.map { String(format: "%02hhx", $0) }.joined()
        } catch {
            print("Failed to read file: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func checkHash(path: URL, expected expectedHashString: String?) -> Bool {
        if let expectedHashString = expectedHashString {
            if let actualHashString = calculateSHA1Hash(for: path) {
                return actualHashString == expectedHashString
            } else {
                return false
            }
        } else {
            return true
        }
    }
}
