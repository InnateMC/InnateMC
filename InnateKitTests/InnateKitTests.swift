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

import XCTest
import InnateKit

class InnateKitTests: XCTestCase {
    private var manifest: [ManifestVersion] = []

    override func setUpWithError() throws {
        try FileManager.default.removeItem(at: FileHandler.assetsFolder)
        let _ = try FileHandler.getOrCreateFolder("Assets")
        manifest = try VersionManifest.download()
    }

    override func tearDownWithError() throws {
        manifest = []
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
        let assetIndex = try AssetIndex.get(version: manifestVer.id, urlStr: version.assetIndex.url)
        let progress: DownloadProgress = try assetIndex.downloadParallel()
        while (!progress.isDone()) {
            print(progress.current)
            print(progress.total)
            Thread.sleep(forTimeInterval: 2)
        }
    }
    
    func testDownloadLibraries() throws {
        let manifestVer = manifest.randomElement()!
        let version = try Version.download(manifestVer.url, sha1: manifestVer.sha1)
        let progress: DownloadProgress = version.downloadLibraries()
        while (!progress.isDone()) {
            print(progress.current)
            print(progress.total)
            Thread.sleep(forTimeInterval: 2)
        }
    }
}
