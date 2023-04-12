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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Foundation
import CryptoKit

public struct ParallelDownloader {
    public static func download(_ tasks: [DownloadTask], progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (ParallelDownloadError) -> Void) -> URLSession {
        progress.current = 0
        progress.total = tasks.count
        
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: nil)
        
        let downloadGroup = DispatchGroup()
        
        for (_, task) in tasks.enumerated() {
            downloadGroup.enter()
            
            let taskUrl = task.sourceUrl
            let downloadTask = session.downloadTask(with: taskUrl) { (tempUrl, response, error) in
                if error != nil {
                    session.invalidateAndCancel()
                    DispatchQueue.main.async {
                        onError(ParallelDownloadError.downloadFailed(errorKey: "error_downloading"))
                    }
                    return
                } else if let tempUrl = tempUrl {
                    do {
                        // TODO: verify sha hash
                        let fileManager = FileManager.default
                        let destinationUrl = task.filePath
                        var fileExists = fileManager.fileExists(atPath: destinationUrl.path)
                        if fileExists {
                            if !checkHash(path: destinationUrl, expected: task.sha1) {
                                do {
                                    try fileManager.removeItem(at: destinationUrl)
                                } catch {
                                    throw ParallelDownloadError.downloadFailed(errorKey: "error_deleting_corrupt_item")
                                }
                            }
                        }
                        if !checkHash(path: tempUrl, expected: task.sha1) {
                            throw ParallelDownloadError.downloadFailed(errorKey: "invalid_sha_hash_error")
                        }
                        fileExists = fileManager.fileExists(atPath: destinationUrl.path)
                        if !fileExists {
                            do {
                                try fileManager.createDirectory(at: destinationUrl.deletingLastPathComponent(), withIntermediateDirectories: true)
                                try fileManager.moveItem(at: tempUrl, to: destinationUrl)
                            } catch {
                                throw ParallelDownloadError.downloadFailed(errorKey: "error_creating_file")
                            }
                        }
                        DispatchQueue.main.async {
                            progress.inc()
                        }
                    } catch {
                        session.invalidateAndCancel()
                        if let error = error as? ParallelDownloadError {
                            DispatchQueue.main.async {
                                onError(error)
                            }
                        } else {
                            DispatchQueue.main.async {
                                onError(ParallelDownloadError.downloadFailed(errorKey: "error_unknown"))
                            }
                        }
                    }
                }
                downloadGroup.leave()
            }
            
            downloadTask.resume()
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

public enum ParallelDownloadError: Error {
    case downloadFailed(errorKey: String)
}
