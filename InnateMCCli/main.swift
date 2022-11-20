//
//  main.swift
//  InnateMCCli
//
//  Created by Shrish Deshpande on 11/18/22.
//

import Foundation
import InnateKit

print("Hello, World!")
#if DEBUG
DataHandler.createTestInstances()
let versions = try VersionManifest.download()
for version in versions {
    print(version.id + " " + version.type)
}
#endif
