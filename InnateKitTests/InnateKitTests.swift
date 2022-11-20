//
//  InnateKitTests.swift
//  InnateKitTests
//
//  Created by Shrish Deshpande on 11/20/22.
//

import XCTest
import InnateKit

class InnateKitTests: XCTestCase {
    override func setUpWithError() throws {
        DataHandler.getOrCreateFolder()
    }

    override func tearDownWithError() throws {
    }

    func testInstancesCreation() throws {
        DataHandler.createTestInstances()
    }

    func testDownloadVersionManifest() throws {
        measure {
            let _ = try! VersionManifest.download()
        }
    }
}
