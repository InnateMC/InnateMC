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
import Combine

struct MicrosoftAuthentication {
    static func authenticateWithXBL(msAccessToken: String) async throws -> XboxAuthResponse {
        let xboxLiveParameters = XboxLiveAuth.fromToken(msAccessToken)
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let url = URL(string: "https://user.auth.xboxlive.com/user/authenticate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: xboxLiveParameters, options: [])
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw MicrosoftAuthError.xboxErrorResponse
            }
            
            do {
                let result = try JSONDecoder().decode(XboxAuthResponse.self, from: data)
                return result
            } catch {
                throw MicrosoftAuthError.xboxInvalidResponse
            }
        } catch {
            throw MicrosoftAuthError.xboxCouldNotConnect
        }
    }
    
    static func authenticateWithXSTS(xblToken: String) async throws -> XboxAuthResponse {
        let xstsAuthParameters = XstsAuth.fromXblToken(xblToken)
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let url = URL(string: "https://xsts.auth.xboxlive.com/xsts/authorize")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.httpBody = try! JSONEncoder().encode(xstsAuthParameters)
        
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw MicrosoftAuthError.xstsErrorResponse
            }
            
            do {
                let result = try JSONDecoder().decode(XboxAuthResponse.self, from: data)
                return result
            } catch {
                throw MicrosoftAuthError.xstsInvalidResponse
            }
        } catch {
            throw MicrosoftAuthError.xstsCouldNotConnect
        }
    }
    
    static func authenticateWithMinecraft(using auth: MinecraftAuth) async throws -> MinecraftAuthResponse {
        let url = URL(string: "https://api.minecraftservices.com/authentication/login_with_xbox")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(auth)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw MicrosoftAuthError.minecraftErrorResponse
            }
            
            do {
                let result = try JSONDecoder().decode(MinecraftAuthResponse.self, from: data)
                return result
            } catch {
                throw MicrosoftAuthError.minecraftInvalidResponse
            }
        } catch {
            throw MicrosoftAuthError.minecraftCouldNotConnect
        }
    }
    
    static func createMsAccount(code: String, clientId: String) async throws -> MicrosoftAccessToken {
        let msParameters: [String: String] = [
            "client_id": clientId,
            "scope": "XboxLive.signin offline_access",
            "code": code,
            "redirect_uri": "http://localhost:1989",
            "grant_type": "authorization_code"
        ]
        
        let url = URL(string: "https://login.microsoftonline.com/consumers/oauth2/v2.0/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = msParameters.percentEncoded()

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                throw MicrosoftAuthError.microsoftErrorResponse
            }

            do {
                let token = try MicrosoftAccessToken.fromJson(json: data)
                return token
            } catch {
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
        } catch {
            throw MicrosoftAuthError.microsoftCouldNotConnect
        }
    }
}
