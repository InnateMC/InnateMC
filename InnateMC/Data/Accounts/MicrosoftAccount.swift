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
import Darwin

struct MicrosoftAccount: MinecraftAccount {
    private static let decoder = JSONDecoder()
    var type: MinecraftAccountType = .microsoft
    var profile: MinecraftProfile
    var token: MicrosoftAccessToken
    var username: String {
        profile.name
    }
    var id: UUID {
        UUID(uuidString: hyphenateUuid(profile.id))!
    }
    var xuid: String {
        username // TODO: decode JWT?
    }
    
    public init(profile: MinecraftProfile, token: MicrosoftAccessToken) {
        self.profile = profile
        self.token = token
    }
    
    func createAccessToken() async throws -> String {
        let manager = LauncherData.instance.accountManager
        
        if token.hasExpired() {
            do {
                let newToken = try await manager.refreshMicrosoftToken(self.token)
                let newAccount = MicrosoftAccount(profile: self.profile, token: newToken)
                manager.accounts[self.id] = newAccount
                DispatchQueue.global(qos: .utility).async {
                    manager.saveThrow()
                }
                return try await newAccount.createAccessToken()
            } catch let err as MicrosoftAuthError {
                NSLog("Error refreshing token - this will lead to undefined results - \(err.localizedDescription)")
                return "nou"
            } catch {
                fatalError("no this cant happen")
            }
        }
        
        let xblResponse = try await manager.authenticateWithXBL(msAccessToken: self.token.token)
        let xstsResponse: XboxAuthResponse = try await manager.authenticateWithXSTS(xblToken: xblResponse.token)
        let mcResponse: MinecraftAuthResponse = try await manager.authenticateWithMinecraft(using: .init(xsts: xstsResponse))
        NSLog(String(data: try! JSONEncoder().encode(mcResponse), encoding: .utf8)!)
        return mcResponse.accessToken
    }
}

private func hyphenateUuid(_ thing: String) -> String {
    var uuid = thing
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 8))
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 13))
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 18))
    uuid.insert("-", at: uuid.index(uuid.startIndex, offsetBy: 23))
    return uuid
}
