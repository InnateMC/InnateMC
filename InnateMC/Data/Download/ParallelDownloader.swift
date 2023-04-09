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

public struct ParallelDownloader {
    public static func downloadParallel(_ tasks: [DownloadTask], progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping () -> Void) -> URLSession {
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 10
        sessionConfig.timeoutIntervalForResource = 10
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let downloadGroup = DispatchGroup()
        var downloadErrors = [Error]()
        
        for (_, task) in tasks.enumerated() {
            downloadGroup.enter()
            
            let taskUrl = task.sourceUrl
            let downloadTask = session.downloadTask(with: taskUrl) { (tempUrl, response, error) in
                if error != nil {
                    session.invalidateAndCancel()
                    DispatchQueue.main.async {
                        onError()
                    }
                    return
                } else if let tempUrl = tempUrl {
                    do {
                        let fileManager = FileManager.default
                        let destinationUrl = task.filePath
                        let fileExists = try destinationUrl.checkResourceIsReachable()
                        if fileExists {
                            try fileManager.removeItem(at: destinationUrl)
                        }
                        try fileManager.moveItem(at: tempUrl, to: destinationUrl)
                        DispatchQueue.main.async {
                            progress.inc()
                        }
                    } catch {
                        downloadErrors.append(error)
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
}
