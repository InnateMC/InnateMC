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
        DataHandler.getOrCreateFolder()
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
}
