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

public struct FabricMeta {
    static func `get`(path: String) -> Http.RequestBuilder {
        return Http.get("https://meta.fabricmc.net/\(path)")
    }
    
    static func requestFabricLoaderVersions() -> Http.RequestBuilder {
        return Self.get(path: "/v2/versions/loader")
    }
    
    static func requestProfile(gameVersion: String, loaderVersion: String) -> Http.RequestBuilder {
        return Self.get(path: "/v2/versions/loader/\(gameVersion)/\(loaderVersion)/profile/json")
    }
    
    static func getFabricLoaderVersions() async throws -> [FabricLoaderVersion] {
        do {
            let (data, response) = try await Self.requestFabricLoaderVersions().request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from fabric meta while fetching profile")
                throw FabricMetaError.loaderVersionsInvalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode([FabricLoaderVersion].self, from: data)
                return result
            } catch {
                logger.error("Received malformed response from fabric meta while fetching profile", error: error)
                throw FabricMetaError.loaderVersionsInvalidResponse
            }
        } catch let err as FabricMetaError {
            throw err
        } catch {
            throw FabricMetaError.loaderVersionsCouldNotConnect
        }
    }
    
    static func getProfile(gameVersion: String, loaderVersion: String) async throws -> Version {
        do {
            let (data, response) = try await Self.requestProfile(gameVersion: gameVersion, loaderVersion: loaderVersion).request()
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from fabric meta while fetching profile")
                throw FabricMetaError.profileInvalidResponse
            }
            
            do {
                print(String(data: data, encoding: .utf8)!)
                let result = try JSONDecoder().decode(Version.self, from: data)
                return result
            } catch {
                logger.error("Received malformed response from fabric meta while fetching profile", error: error)
                throw FabricMetaError.profileInvalidResponse
            }
        } catch let err as FabricMetaError {
            throw err
        } catch {
            throw FabricMetaError.profileCouldNotConnect
        }
    }
    
    enum FabricMetaError: Error {
        case loaderVersionsInvalidResponse
        case loaderVersionsCouldNotConnect
        case profileInvalidResponse
        case profileCouldNotConnect
    }
}
