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

public struct MainDownloads: Codable, Equatable {
    public static let none: MainDownloads = .init(client: .none, clientMappings: .none, server: .none, serverMappings: .none)
    let client: Artifact
    let clientMappings: Artifact
    let server: Artifact
    let serverMappings: Artifact
    
    enum CodingKeys: String, CodingKey {
        case client
        case clientMappings = "client_mappings"
        case server
        case serverMappings = "server_mappings"
    }
    
    public static func |(lhs: MainDownloads, rhs: MainDownloads) -> MainDownloads {
        let mergedClient = lhs.client != .none ? lhs.client : rhs.client
        let mergedClientMappings = lhs.clientMappings != .none ? lhs.clientMappings : rhs.clientMappings
        let mergedServer = lhs.server != .none ? lhs.server : rhs.server
        let mergedServerMappings = lhs.serverMappings != .none ? lhs.serverMappings : rhs.serverMappings
        
        return MainDownloads(client: mergedClient, clientMappings: mergedClientMappings, server: mergedServer, serverMappings: mergedServerMappings)
    }
}
