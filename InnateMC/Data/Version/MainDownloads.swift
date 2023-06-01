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
    public static let none: MainDownloads = .init(client: .none, clientMappings: nil, server: nil, serverMappings: nil, windowsServer: nil)
    let client: Artifact
    let clientMappings: Artifact?
    let server: Artifact?
    let serverMappings: Artifact?
    let windowsServer: Artifact?
    
    enum CodingKeys: String, CodingKey {
        case client
        case clientMappings = "client_mappings"
        case server
        case serverMappings = "server_mappings"
        case windowsServer = "windows_server"
    }
    
    public static func |(lhs: MainDownloads, rhs: MainDownloads) -> MainDownloads {
        let mergedClient = lhs.client != .none ? lhs.client : rhs.client
        let mergedClientMappings = lhs.clientMappings != nil ? lhs.clientMappings : rhs.clientMappings
        let mergedServer = lhs.server != nil ? lhs.server : rhs.server
        let mergedServerMappings = lhs.serverMappings != nil ? lhs.serverMappings : rhs.serverMappings
        let mergedWindowsServer = lhs.windowsServer != nil ? lhs.windowsServer : rhs.windowsServer
        
        return MainDownloads(client: mergedClient, clientMappings: mergedClientMappings, server: mergedServer, serverMappings: mergedServerMappings, windowsServer: mergedWindowsServer)
    }
}
