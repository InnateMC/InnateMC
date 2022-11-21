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
        try FileManager.default.removeItem(at: FolderHandler.assetsFolder)
        try FolderHandler.getOrCreateFolder("Assets")
        manifest = try VersionManifest.download()
    }

    override func tearDownWithError() throws {
        manifest = []
    }

    func testInstancesCreation() throws {
        try Instance.createTestInstances()
    }

    func testDownloadVersionManifest() throws {
        measure {
            let _ = try! VersionManifest.download()
        }
    }
    
    func testDownloadVersion() throws {
        measure {
            let manifestVer = manifest.randomElement()!
            let _ = try! Version.download(manifestVer.url, sha1: manifestVer.sha1)
        }
    }
    
    func testDownloadAssets() throws {
        let manifestVer = manifest.randomElement()!
        let version = try Version.download(manifestVer.url, sha1: manifestVer.sha1)
        let assetIndex = try AssetIndex.download(version: manifestVer.id, urlStr: version.assetIndex.url)
        let progress: DownloadProgress = try assetIndex.downloadParallel()
        var last = -1
        while (!progress.isDone()) {
            let per = progress.intPercent()
            if (last != per) {
                print(per)
                last = per
            }
        }
    }
}
