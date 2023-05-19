//
// Copyright © 2022 InnateMC and contributors
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
import CryptoKit

public struct OldVersion {
    public let arguments: OldArguments
    public let assetIndex: PartialAssetIndex
    public let downloads: Downloads
    public let id: String
    public let libraries: [Library]
    public let mainClass: String
    public let type: String
    public let releaseTime: String

    public static func download(_ url: String, sha1: String?) throws -> Version {
        if let url = URL(string: url) {
            return try download(url, sha1: sha1)
        } else {
            fatalError("Invalid url")
        }
    }

    public static func download(_ url: URL, sha1: String?) throws -> Version {
        let contents = try Data(contentsOf: url)
        let realSha = Insecure.SHA1.hash(data: contents).compactMap { String(format: "%02x", $0) }.joined()
        if realSha != sha1 {
            print("Invalid SHA hash for version json \(url.path), ignoring")
        }
        let json = try JSONSerialization.jsonObject(with: contents) as! [String:Any]
        return deserialize(json)
    }

    public static func deserialize(_ dict: [String: Any]) -> Version {
        let args = Arguments.deserialize(dict)
        let assetIndex = PartialAssetIndex.deserialize(dict["assetIndex"] as! [String:Any])
        let downloads = Downloads.deserialize(dict["downloads"] as! [String:Any])
        let id = dict["id"] as! String
        let libraries = Library.deserializeArray(dict["libraries"] as! [Any])
        let mainClass = dict["mainClass"] as! String
        let type = dict["type"] as! String
        let releaseTime = dict["releaseTime"] as! String
        return Version(arguments: args, assetIndex: assetIndex, downloads: downloads, id: id, libraries: libraries, mainClass: mainClass, type: type, releaseTime: releaseTime)
    }
    
    public struct OldDownloads {
        public let client: Download
        
        public struct OldDownload {
            public let sha1: String
            public let url: String
            
            public init(sha1: String, url: String) {
                self.sha1 = sha1
                self.url = url
            }
            
            public static func deserialize(_ downloadObj: [String: Any]) -> Download {
                Download(sha1: downloadObj["sha1"] as! String, url: downloadObj["url"] as! String)
            }
        }

        public static func deserialize(_ downloadsObj: [String: Any]) -> Downloads {
            Downloads(client: Download.deserialize(downloadsObj["client"] as! [String:Any]))
        }
    }

    public struct OldLibrary {
        public let downloads: Downloads
        public let name: String
        
        public struct OldDownloads {
            public let artifact: Artifact
            
            public init(artifact: Artifact) {
                self.artifact = artifact
            }
            
            public struct OldArtifact {
                public let path: String
                public let sha1: String
                public let url: String

                public static func deserialize(_ artifactObj: [String: Any]) -> Artifact {
                    Artifact(path: artifactObj["path"] as! String, sha1: artifactObj["sha1"] as! String, url: artifactObj["url"] as! String)
                }
            }

            public static func deserialize(_ downloadsObj: [String: Any]) -> Downloads {
                let artifactObj = downloadsObj["artifact"]
                if let artifactObj = artifactObj {
                    return Downloads(artifact: Artifact.deserialize(artifactObj as! [String:Any]))
                }
                return Downloads(artifact: Artifact.deserialize((downloadsObj["classifiers"] as! [String:Any])["natives-osx"] as! [String:Any]))
            }
        }
        
        public static func deserializeArray(_ librariesArray: [Any]) -> [Library] {
            var libraries: [Library] = []
            for libraryJson in librariesArray {
                if libraryJson is [String:Any] {
                    let lib = deserialize(libraryJson as! [String:Any])
                    if let lib = lib {
                        libraries.append(lib)
                    }
                }
            }
            return libraries
        }
        
        public static func deserialize(_ libraryObj: [String: Any]) -> Library? {
            let rulesArr = libraryObj["rules"] as? [Any]
            if let rulesArr = rulesArr {
                let rules = Rule.deserializeArray(rulesArr)
                for rule in rules {
                    if !rule.shouldAllow() {
                        return nil
                    }
                }
            }
            return Library(downloads: Downloads.deserialize(libraryObj["downloads"] as! [String:Any]), name: libraryObj["name"] as! String)
        }
    }

    public struct OldRule {
        public let action: String
        public let os: OS

        public struct OldOS {
            public var name: String?
            public var arch: String?

            public static func deserialize(_ osObj: [String: Any]?) -> OS {
                guard let osObj = osObj else {
                    return OS(name: "osx", arch: nil)
                }
                return OS(name: osObj["name"] as? String, arch: osObj["arch"] as? String)
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
        
        public static func deserialize(_ ruleObj: [String: Any]) -> Rule {
            Rule(action: ruleObj["action"] as! String, os: OS.deserialize(ruleObj["os"] as? [String:Any]))
        }

        public static func deserializeArray(_ rulesArray: [Any]) -> [Rule] {
            var rules: [Rule] = []
            for ruleJson in rulesArray {
                if ruleJson is [String:Any] {
                    rules.append(deserialize(ruleJson as! [String:Any]))
                }
            }
            return rules
        }
    }
}

extension PartialAssetIndex {
    public static func deserialize(_ assetIndexObj: [String: Any]) -> PartialAssetIndex {
        PartialAssetIndex(id: assetIndexObj["id"] as! String, sha1: assetIndexObj["sha1"] as! String, url: assetIndexObj["url"] as! String)
    }
}

extension Arguments {
    public static func deserialize(_ argumentsObj: [String: Any]) -> Arguments {
        let root = argumentsObj["arguments"] as? [String:Any]
        guard let root = root else {
            return Arguments(game: [argumentsObj["minecraftArguments"] as! String], jvm: [])
        }
        let gameArr = root["game"] as! [Any]
        var gameArgs: [String] = []
        for gameJson in gameArr {
            if gameJson is String {
                gameArgs.append(gameJson as! String)
            }
        }
        let jvmArr = root["jvm"] as! [Any]
        var jvmArgs: [String] = []
        for jvmJson in jvmArr {
            if jvmJson is String {
                jvmArgs.append(jvmJson as! String)
            }
            else if let jvmJson = jvmJson as? [String:Any] {
                let rules = jvmJson["rules"] as! [Any]
                for rule in rules {
                    if let rule = rule as? [String:Any] {
                        if rule["action"] as! String == "allow" && (rule["os"] as? [String:Any])?["name"] as? String == "osx" {
                            // actual bruh moment
                            jvmArgs.append(contentsOf: jvmJson["value"] as! [String])
                            break
                            
                        }
                    }
                }
            }
        }
        print(jvmArgs)
        return Arguments(game: gameArgs, jvm: jvmArgs)
    }
}
