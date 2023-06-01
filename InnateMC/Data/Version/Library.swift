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
// along with this program.  If not, see http://www.gnu.org/licenses/
//

import Foundation

public struct Library: Codable, Equatable {
    public let downloads: LibraryDownloads
    public let name: String
    public let rules: [Rule]?
    
    public init(downloads: LibraryDownloads, name: String, rules: [Rule]?) {
        self.downloads = downloads
        self.name = name
        self.rules = rules
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let artifact = try? container.decode(ConcLibrary.self) {
            self.downloads = LibraryDownloads(artifact: LibraryArtifact(path: artifact.mavenStringToPath(), url: URL(string: artifact.mavenUrl())!, sha1: nil, size: nil))
            self.name = artifact.name
            self.rules = nil
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
            self.downloads = try container.decode(LibraryDownloads.self, forKey: .downloads)
            self.rules = try container.decodeIfPresent([Rule].self, forKey: .rules)
        }
    }
    
    public struct ConcLibrary: Codable {
        public let name: String
        public let url: String
        
        func mavenStringToPath() -> String {
            let components = self.name.components(separatedBy: ":")
            let group = components[0].replacingOccurrences(of: ".", with: "/")
            let artifact = components[1].replacingOccurrences(of: ".", with: "/")
            let version = components[2]
            let path = "\(group)/\(artifact)/\(version)"
            
            return path
        }
        
        func mavenUrl() -> String {
            return "\(url)\(mavenStringToPath())"
        }
    }
}

public struct LibraryDownloads: Codable, Equatable {
    public var artifact: LibraryArtifact?
    public var classifiers: LibraryClassifiers? = nil
    
    public struct LibraryClassifiers: Codable, Equatable {
        var nativesOsx: LibraryArtifact?
        
        public enum CodingKeys: String, CodingKey {
            case nativesOsx = "natives-osx"
        }
    }
    
    public var artifacts: [LibraryArtifact] {
        var arr: [LibraryArtifact] = []
        if let classifiers = classifiers, let natives = classifiers.nativesOsx {
            arr.append(natives)
        }
        if let artifact = self.artifact {
            arr.append(artifact)
        }
        return arr
    }
}
