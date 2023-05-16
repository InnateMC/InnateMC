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

extension AccountManager {
    public func setupMicrosoftAccount(code: String) {
        print("your face is \(code)")
        
        guard let msAccountViewModel = self.msAccountViewModel else {
            return
        }
        
        Task(priority: .high) {
            do {
                let msAccessToken: MicrosoftAccessToken = try await self.authenticateWithMicrosoft(code: code, clientId: self.clientId)
                DispatchQueue.main.async {
                    msAccountViewModel.setAuthWithXboxLive()
                }
                logger.debug("Authenticated with microsoft")
                let xblResponse = try await self.authenticateWithXBL(msAccessToken: msAccessToken.token)
                DispatchQueue.main.async {
                    msAccountViewModel.setAuthWithXboxXSTS()
                }
                logger.debug("Authenticated with xbox live")
                let xstsResponse: XboxAuthResponse = try await self.authenticateWithXSTS(xblToken: xblResponse.token)
                DispatchQueue.main.async {
                    msAccountViewModel.setAuthWithMinecraft()
                }
                logger.debug("Authenticated with xbox xsts")
                let mcResponse: MinecraftAuthResponse = try await self.authenticateWithMinecraft(using: .init(xsts: xstsResponse))
                DispatchQueue.main.async {
                    msAccountViewModel.setFetchingProfile()
                }
                logger.debug("Authenticated with minecraft")
                let profile: MinecraftProfile = try await self.getProfile(accessToken: mcResponse.accessToken)
                logger.debug("Fetched minecraft profile")
                let account: MicrosoftAccount = .init(profile: profile, token: msAccessToken)
                self.accounts[account.id] = account
                logger.info("Successfully added microsoft account \(profile.name)")
                DispatchQueue.main.async {
                    msAccountViewModel.closeSheet()
                    self.msAccountViewModel = nil
                }
            } catch let error as MicrosoftAuthError {
                logger.error("Caught error during authentication", error: error)
                DispatchQueue.main.async {
                    msAccountViewModel.error(error)
                    self.msAccountViewModel = nil
                }
                return
            } catch {
                fatalError("Unknown error - this is bug - \(error)")
            }
        }
    }
    
    func authenticateWithMinecraft(using auth: MinecraftAuth) async throws -> MinecraftAuthResponse {
        let url = URL(string: "https://api.minecraftservices.com/authentication/login_with_xbox")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(auth)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from minecraft authentication server")
                throw MicrosoftAuthError.minecraftInvalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode(MinecraftAuthResponse.self, from: data)
                return result
            } catch {
                logger.error("Received malformed response from minecraft authentication server", error: error)
                throw MicrosoftAuthError.minecraftInvalidResponse
            }
        } catch let err as MicrosoftAuthError {
            throw err
        } catch {
            throw MicrosoftAuthError.minecraftCouldNotConnect
        }
    }
    
    func authenticateWithXBL(msAccessToken: String) async throws -> XboxAuthResponse {
        let xboxLiveParameters = XboxLiveAuth.fromToken(msAccessToken)
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        let url = URL(string: "https://user.auth.xboxlive.com/user/authenticate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(xboxLiveParameters)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from xbox live authentication server")
                throw MicrosoftAuthError.xboxInvalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode(XboxAuthResponse.self, from: data)
                return result
            } catch {
                logger.error("Received malformed response from xbox live authentication server", error: error)
                throw MicrosoftAuthError.xboxInvalidResponse
            }
        } catch let err as MicrosoftAuthError {
            throw err
        } catch {
            throw MicrosoftAuthError.xboxCouldNotConnect
        }
    }
    
    func authenticateWithXSTS(xblToken: String) async throws -> XboxAuthResponse {
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
                logger.error("Received invalid status code from xbox xsts authentication server")
                throw MicrosoftAuthError.xstsInvalidResponse
            }
            
            do {
                let result = try JSONDecoder().decode(XboxAuthResponse.self, from: data)
                return result
            } catch {
                logger.error("Received malformed response from xbox xsts authentication server", error: error)
                throw MicrosoftAuthError.xstsInvalidResponse
            }
        } catch let err as MicrosoftAuthError {
            throw err
        } catch {
            throw MicrosoftAuthError.xstsCouldNotConnect
        }
    }
    
    func authenticateWithMicrosoft(code: String, clientId: String) async throws -> MicrosoftAccessToken {
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
                logger.error("Received invalid status code from microsoft authentication server")
                throw MicrosoftAuthError.microsoftInvalidResponse
            }

            do {
                let token = try MicrosoftAccessToken.fromJson(json: data)
                return token
            } catch {
                logger.error("Received malformed response from microsoft authentication server", error: error)
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
        } catch let err as MicrosoftAuthError {
            throw err
        } catch {
            throw MicrosoftAuthError.microsoftCouldNotConnect
        }
    }
    
    func refreshMicrosoftToken(_ token: MicrosoftAccessToken) async throws -> MicrosoftAccessToken {
        let msParameters: [String: String] = [
            "client_id": clientId,
            "scope": "XboxLive.signin offline_access",
            "refresh_token": token.refreshToken,
            "grant_type": "refresh_token"
        ]
        
        let url = URL(string: "https://login.microsoftonline.com/consumers/oauth2/v2.0/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = msParameters.percentEncoded()
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from microsoft refresh server")
                throw MicrosoftAuthError.microsoftInvalidResponse
            }

            do {
                let token = try MicrosoftAccessToken.fromJson(json: data)
                return token
            } catch {
                logger.error("Received malformed response from microsoft refresh server", error: error)
                throw MicrosoftAuthError.microsoftInvalidResponse
            }
        } catch let err as MicrosoftAuthError {
            throw err
        } catch {
            throw MicrosoftAuthError.microsoftCouldNotConnect
        }
    }
    
    func getProfile(accessToken: String) async throws -> MinecraftProfile {
        let url = URL(string: "https://api.minecraftservices.com/minecraft/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                logger.error("Received invalid status code from minecraft profile server")
                throw MicrosoftAuthError.profileInvalidResponse
            }

            do {
                let token = try JSONDecoder().decode(MinecraftProfile.self, from: data)
                return token
            } catch {
                logger.error("Received malformed response from minecraft profile server", error: error)
                throw MicrosoftAuthError.profileInvalidResponse
            }
        } catch let err as MicrosoftAuthError {
            throw err
        } catch {
            throw MicrosoftAuthError.profileCouldNotConnect
        }
    }
}
