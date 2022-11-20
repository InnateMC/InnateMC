//
//  Version.swift
//  InnateKit
//
//  Created by Shrish Deshpande on 11/20/22.
//

import Foundation
import InnateJson

public struct Version {
    public let arguments: Arguments
    public let assetIndex: PartialAssetIndex
    public let downloads: Downloads
    public let libraries: [Library]
    public let mainClass: String
    public let type: String

    public static func download(_ url: String, sha1: String) throws -> Version {
        if let url = URL(string: url) {
            let contents = try String(contentsOf: url)
            let json = InnateParser.readJson(contents)!
            return parse(json)
        } else {
            fatalError("Invalid url")
        }
    }
    
    public static func parse(_ dict: [String: InnateValue]) -> Version {
        let args = Arguments.parse(dict["arguments"]!.asObject()!)
        let assetIndex = PartialAssetIndex.parse(dict["assetIndex"]!.asObject()!)
        let downloads = Downloads.parse(dict["downloads"]!.asObject()!)
        let libraries = Library.parseArray(dict["libraries"]!.asArray()!)
        let mainClass = dict["mainClass"]!.asString()!
        let type = dict["type"]!.asString()!
        return Version(arguments: args, assetIndex: assetIndex, downloads: downloads, libraries: libraries, mainClass: mainClass, type: type)
    }
    
    public struct Arguments {
        public let game: [String]
        public let jvm: [String]
        
        public static func parse(_ argumentsObj: [String: InnateValue]) -> Arguments {
            let gameArr = argumentsObj["game"]!.asArray()!
            var gameArgs: [String] = []
            for gameJson in gameArr {
                if gameJson.isString() {
                    gameArgs.append(gameJson.asString()!)
                }
            }
            let jvmArr = argumentsObj["jvm"]!.asArray()!
            var jvmArgs: [String] = []
            for jvmJson in jvmArr {
                if jvmJson.isString() {
                    jvmArgs.append(jvmJson.asString()!)
                }
            }
            return Arguments(game: gameArgs, jvm: jvmArgs)
        }
    }
    
    public struct PartialAssetIndex {
        public let id: String
        public let sha1: String
        public let size: Int
        public let totalSize: Int
        public let url: String
        
        public static func parse(_ assetIndexObj: [String: InnateValue]) -> PartialAssetIndex {
            PartialAssetIndex(id: assetIndexObj["id"]!.asString()!, sha1: assetIndexObj["sha1"]!.asString()!, size: assetIndexObj["size"]!.asNumber()!.intValue, totalSize: assetIndexObj["totalSize"]!.asNumber()!.intValue, url: assetIndexObj["url"]!.asString()!)
        }
    }
    
    public struct Downloads {
        public let client: Download
        
        public struct Download {
            public let sha1: String
            public let size: Int
            public let url: String
            
            public static func parse(_ downloadObj: [String: InnateValue]) -> Download {
                Download(sha1: downloadObj["sha1"]!.asString()!, size: downloadObj["size"]!.asNumber()!.intValue, url: downloadObj["url"]!.asString()!)
            }
        }

        public static func parse(_ downloadsObj: [String: InnateValue]) -> Downloads {
            Downloads(client: Download.parse(downloadsObj["client"]!.asObject()!))
        }
    }

    public struct Library {
        public let downloads: Downloads
        public let name: String
        
        public struct Downloads {
            public let artifact: Artifact
            
            public struct Artifact {
                public let path: String
                public let sha1: String
                public let size: Int
                public let url: String

                public static func parse(_ artifactObj: [String: InnateValue]) -> Artifact {
                    Artifact(path: artifactObj["path"]!.asString()!, sha1: artifactObj["sha1"]!.asString()!, size: artifactObj["size"]!.asNumber()!.intValue, url: artifactObj["url"]!.asString()!)
                }
            }

            public static func parse(_ downloadsObj: [String: InnateValue]) -> Downloads {
                Downloads(artifact: Artifact.parse(downloadsObj["artifact"]!.asObject()!))
            }
        }
        
        public static func parseArray(_ librariesArray: [InnateValue]) -> [Library] {
            var libraries: [Library] = []
            for libraryJson in librariesArray {
                if libraryJson.isObject() {
                    let lib = parse(libraryJson.asObject()!)
                    if let lib = lib {
                        libraries.append(lib)
                    }
                }
            }
            return libraries
        }
        
        public static func parse(_ libraryObj: [String: InnateValue]) -> Library? {
            let rulesArr = libraryObj["rules"]!.asArray()
            if let rulesArr = rulesArr {
                let rules = Rule.parseArray(rulesArr)
                for rule in rules {
                    if !rule.shouldAllow() {
                        return nil
                    }
                }
            }
            return Library(downloads: Downloads.parse(libraryObj["downloads"]!.asObject()!), name: libraryObj["name"]!.asString()!)
        }
    }

    public struct Rule {
        public let action: String
        public let os: OS

        public struct OS {
            public let name: String?
            public let arch: String?

            public static func parse(_ osObj: [String: InnateValue]) -> OS {
                OS(name: osObj["name"]?.asString(), arch: osObj["arch"]?.asString())
            }
        }

        public func shouldAllow() -> Bool {
            if action == "allow" {
                return os.name == nil || os.name == "osx"
            } else if action == "disallow" {
                return os.name != nil && os.name != "osx"
            }
            fatalError("Bad type")
        }
        
        public static func parse(_ ruleObj: [String: InnateValue]) -> Rule {
            Rule(action: ruleObj["action"]!.asString()!, os: OS.parse(ruleObj["os"]!.asObject()!))
        }

        public static func parseArray(_ rulesArray: [InnateValue]) -> [Rule] {
            var rules: [Rule] = []
            for ruleJson in rulesArray {
                if ruleJson.isObject() {
                    rules.append(parse(ruleJson.asObject()!))
                }
            }
            return rules
        }
    }
}
