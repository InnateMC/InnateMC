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

import CoreFoundation
import Foundation

public struct MicrosoftAccessToken: Codable {
    public var token: String
    public var expiry: Int
    public var refreshToken: String
    
    public init(token: String, expiry: Int, refreshToken: String) {
        self.token = token
        self.expiry = expiry
        self.refreshToken = refreshToken
    }

    public init(token: String, expiresIn: Int, refreshToken: String) {
        self.token = token
        self.expiry = Int(CFAbsoluteTimeGetCurrent()) + expiresIn
        self.refreshToken = refreshToken
    }
    
    public static func fromJson(json data: Data) throws -> MicrosoftAccessToken {
        do {
            return try JSONDecoder().decode(RawMicrosoftAccessToken.self, from: data).convert()
        } catch {
            throw MicrosoftAuthError.couldNotAuthenticateWithMicrosoft
        }
    }
    
    public func hasExpired() -> Bool {
        return Int(CFAbsoluteTimeGetCurrent()) > expiry - 5
    }
}

struct RawMicrosoftAccessToken: Codable {
    public var access_token: String
    public var refresh_token: String
    public var expires_in: Int
    
    public func convert() -> MicrosoftAccessToken {
        return MicrosoftAccessToken(token: access_token, expiresIn: expires_in, refreshToken: refresh_token)
    }
}
