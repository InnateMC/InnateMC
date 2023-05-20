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

public struct LoggingConfig: Codable, Equatable {
    public static let none: LoggingConfig = .init(client: .none)
    public let client: ClientLoggingConfig
}

public struct ClientLoggingConfig: Codable, Equatable {
    public static let none: ClientLoggingConfig = .init(argument: "", file: .none, type: "")
    public let argument: String
    public let file: LoggingArtifact
    public let type: String
}

public struct LoggingArtifact: Codable, Equatable {
    public static let none: LoggingArtifact = .init(id: "", sha1: "", size: 0, url: URL(string: "/")!)
    public let id: String
    public let sha1: String
    public let size: Int
    public let url: URL
}
