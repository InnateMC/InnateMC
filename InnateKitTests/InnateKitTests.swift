//
//  InnateKitTests.swift
//  InnateKitTests
//
//  Created by Shrish Deshpande on 11/20/22.
//

import XCTest
import InnateKit

class InnateKitTests: XCTestCase {
    private var manifest: [ManifestVersion] = []

    override func setUpWithError() throws {
        try FileManager.default.removeItem(at: DataHandler.getOrCreateFolder("Assets"))
        DataHandler.getOrCreateFolder("Assets")
        manifest = try VersionManifest.download()
    }

    override func tearDownWithError() throws {
        manifest = []
    }

    func testInstancesCreation() throws {
        DataHandler.createTestInstances()
    }

    func testDownloadVersionManifest() throws {
        measure {
            let _ = try! VersionManifest.download()
        }
    }
    
    func testDownloadVersion() throws {
        measure {
            let manifestVer = manifest.randomElement()!
            try! Version.download(manifestVer.url, sha1: manifestVer.sha1)
        }
    }
    
    func testDownloadAssets() throws {
        let manifestVer = manifest.randomElement()!
        let version = try! Version.download(manifestVer.url, sha1: manifestVer.sha1)
        let assetIndex = try! AssetIndex.download(version: manifestVer.id, urlStr: version.assetIndex.url)
        var progress: DownloadProgress = DownloadProgress(current: 0, total: 0)
        try! assetIndex.download(progress: &progress)
    }
}
