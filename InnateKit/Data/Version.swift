//
//  Version.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/20/22.
//

import Foundation
import InnateJson

public struct Version {
    public static func download(_ url: String, sha1: String) throws -> Version {
        if let url = URL(string: url) {
            let contents = try String(contentsOf: url)
            let json = InnateParser.readJson(contents)!
        } else {
            fatalError("Invalid url")
        }
    }
}
