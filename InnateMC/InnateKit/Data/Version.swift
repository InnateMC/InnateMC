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

import Foundation
import InnateJson

public class Version {
    public let arguments: Arguments
    public let assetIndex: PartialAssetIndex
    public let downloads: Downloads
    public let id: String
    public let libraries: [Library]
    public let mainClass: String
    public let type: String
    public let releaseTime: String
    
    public init(arguments: Arguments, assetIndex: PartialAssetIndex, downloads: Downloads, id: String, libraries: [Library], mainClass: String, type: String, releaseTime: String) {
        self.arguments = arguments
        self.assetIndex = assetIndex
        self.downloads = downloads
        self.id = id
        self.libraries = libraries
        self.mainClass = mainClass
        self.type = type
        self.releaseTime = releaseTime
    }

    public static func download(_ url: String, sha1: String?) throws -> Version {
        if let url = URL(string: url) {
            return try download(url, sha1: sha1)
        } else {
            fatalError("Invalid url")
        }
    }

    public static func download(_ url: URL, sha1: String?) throws -> Version {
        let contents = try String(contentsOf: url)
        let json = InnateParser.readJson(contents)!
        // TODO verify sha1
        return deserialize(json)
    }

    public static func deserialize(_ dict: [String: InnateValue]) -> Version {
        let args = Arguments.deserialize(dict)
        let assetIndex = PartialAssetIndex.deserialize(dict["assetIndex"]!.asObject()!)
        let downloads = Downloads.deserialize(dict["downloads"]!.asObject()!)
        let id = dict["id"]!.asString()!
        let libraries = Library.deserializeArray(dict["libraries"]!.asArray()!)
        let mainClass = dict["mainClass"]!.asString()!
        let type = dict["type"]!.asString()!
        let releaseTime = dict["releaseTime"]!.asString()!
        return Version(arguments: args, assetIndex: assetIndex, downloads: downloads, id: id, libraries: libraries, mainClass: mainClass, type: type, releaseTime: releaseTime)
    }
    
    public class Downloads {
        public let client: Download
        
        public init(client: Download) {
            self.client = client
        }
        
        public struct Download {
            public let sha1: String
            public let url: String
            
            public init(sha1: String, url: String) {
                self.sha1 = sha1
                self.url = url
            }
            
            public static func deserialize(_ downloadObj: [String: InnateValue]) -> Download {
                Download(sha1: downloadObj["sha1"]!.asString()!, url: downloadObj["url"]!.asString()!)
            }
        }

        public static func deserialize(_ downloadsObj: [String: InnateValue]) -> Downloads {
            Downloads(client: Download.deserialize(downloadsObj["client"]!.asObject()!))
        }
    }

    public class Library {
        public let downloads: Downloads
        public let name: String
        
        public init(downloads: Downloads, name: String) {
            self.downloads = downloads
            self.name = name
        }
        
        public class Downloads {
            public let artifact: Artifact
            
            public init(artifact: Artifact) {
                self.artifact = artifact
            }
            
            public class Artifact {
                public let path: String
                public let sha1: String
                public let url: String
                
                public init(path: String, sha1: String, url: String) {
                    self.path = path
                    self.sha1 = sha1
                    self.url = url
                }

                public static func deserialize(_ artifactObj: [String: InnateValue]) -> Artifact {
                    Artifact(path: artifactObj["path"]!.asString()!, sha1: artifactObj["sha1"]!.asString()!, url: artifactObj["url"]!.asString()!)
                }
            }

            public static func deserialize(_ downloadsObj: [String: InnateValue]) -> Downloads {
                let artifactObj = downloadsObj["artifact"]
                if let artifactObj = artifactObj {
                    return Downloads(artifact: Artifact.deserialize(artifactObj.asObject()!))
                }
                return Downloads(artifact: Artifact.deserialize(downloadsObj["classifiers"]!.asObject()!["natives-osx"]!.asObject()!))
            }
        }
        
        public static func deserializeArray(_ librariesArray: [InnateValue]) -> [Library] {
            var libraries: [Library] = []
            for libraryJson in librariesArray {
                if libraryJson.isObject() {
                    let lib = deserialize(libraryJson.asObject()!)
                    if let lib = lib {
                        libraries.append(lib)
                    }
                }
            }
            return libraries
        }
        
        public static func deserialize(_ libraryObj: [String: InnateValue]) -> Library? {
            let rulesArr = libraryObj["rules"]?.asArray()
            if let rulesArr = rulesArr {
                let rules = Rule.deserializeArray(rulesArr)
                for rule in rules {
                    if !rule.shouldAllow() {
                        return nil
                    }
                }
            }
            return Library(downloads: Downloads.deserialize(libraryObj["downloads"]!.asObject()!), name: libraryObj["name"]!.asString()!)
        }
    }

    public class Rule {
        public let action: String
        public let os: OS
        
        public init(action: String, os: OS) {
            self.action = action
            self.os = os
        }

        public class OS {
            public let name: String?
            public let arch: String?
            
            public init(name: String?, arch: String?) {
                self.name = name
                self.arch = arch
            }

            public static func deserialize(_ osObj: [String: InnateValue]?) -> OS {
                guard let osObj = osObj else {
                    return OS(name: "osx", arch: nil)
                }
                return OS(name: osObj["name"]?.asString(), arch: osObj["arch"]?.asString())
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
        
        public static func deserialize(_ ruleObj: [String: InnateValue]) -> Rule {
            Rule(action: ruleObj["action"]!.asString()!, os: OS.deserialize(ruleObj["os"]?.asObject()!))
        }

        public static func deserializeArray(_ rulesArray: [InnateValue]) -> [Rule] {
            var rules: [Rule] = []
            for ruleJson in rulesArray {
                if ruleJson.isObject() {
                    rules.append(deserialize(ruleJson.asObject()!))
                }
            }
            return rules
        }
    }
}

extension Version {
    public func downloadLibraries() -> DownloadProgress {
        var tasks: [DownloadTask] = []
        for library in libraries {
            let pathComponents = library.downloads.artifact.path.split(separator: "/")
            var fileUrl = FileHandler.librariesFolder
            for component in pathComponents {
                fileUrl = fileUrl.appendingPathComponent(String(component))
            }
            let task = DownloadTask(url: URL(string: library.downloads.artifact.url)!, filePath: fileUrl, sha1: nil)
            print(task.url)
            print(task.filePath)
            print("")
            tasks.append(task)
        }
        let progress = DownloadProgress()
        ParallelDownloader.download(tasks, progress: progress) {}
        return progress
    }
}

extension PartialAssetIndex {
    public static func deserialize(_ assetIndexObj: [String: InnateValue]) -> PartialAssetIndex {
        PartialAssetIndex(id: assetIndexObj["id"]!.asString()!, sha1: assetIndexObj["sha1"]!.asString()!, url: assetIndexObj["url"]!.asString()!)
    }
}

extension Arguments {
    public static func deserialize(_ argumentsObj: [String: InnateValue]) -> Arguments {
        let root = argumentsObj["arguments"]?.asObject()
        guard let root = root else {
            return Arguments(game: [argumentsObj["minecraftArguments"]!.asString()!], jvm: [])
        }
        let gameArr = root["game"]!.asArray()!
        var gameArgs: [String] = []
        for gameJson in gameArr {
            if gameJson.isString() {
                gameArgs.append(gameJson.asString()!)
            }
        }
        let jvmArr = root["jvm"]!.asArray()!
        var jvmArgs: [String] = []
        for jvmJson in jvmArr {
            if jvmJson.isString() {
                jvmArgs.append(jvmJson.asString()!)
            }
        }
        return Arguments(game: gameArgs, jvm: jvmArgs)
    }
}
