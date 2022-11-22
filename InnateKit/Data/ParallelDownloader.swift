//
//  ParallelDownloader.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/21/22.
//

import Foundation
import CryptoKit

public class ParallelDownloader {
    fileprivate static let dispatchQueue = DispatchQueue(label: "Parallel Downloader")
    
    public static func download(_ tasks: [DownloadTask], progress: DownloadProgress) {
        progress.current = 0
        progress.total = tasks.count
        let fm = FileManager.default

        func dispatch(_ task: DownloadTask) {
            dispatchQueue.async {
                if fm.fileExists(atPath: task.filePath.path) {
                    progress.current += 1
                } else {
                    let data = try! Data(contentsOf: task.url)
                    if (!isSha1Valid(data: data, expected: task.sha1)) {
                        print("INVALID SHA HASH, RETRYING")
                        dispatch(task)
                    } else {
                        let parent = task.filePath.deletingLastPathComponent()
                        if !fm.fileExists(atPath: parent.path) {
                            try! fm.createDirectory(at: parent, withIntermediateDirectories: true)
                        }
                        fm.createFile(atPath: task.filePath.path, contents: data)
                        progress.current += 1
                        progress.current += 1
                    }
                }
            }
        }

        for task in tasks {
            dispatch(task)
        }
    }

    internal static func isSha1Valid(data: Data, expected: String?) -> Bool {
        guard let expected = expected else {
            return true
        }
        return Insecure.SHA1.hash(data: data).description == expected
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
