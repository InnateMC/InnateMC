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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

import Foundation
import Swifter
import CryptoKit

class AccountManager: ObservableObject {
    public static let accountsPath: URL = try! FileHandler.getOrCreateFolder().appendingPathComponent("Accounts.plist")
    public static let plistEncoder = PropertyListEncoder()
    public let server: HttpServer
    public var serverThread: DispatchQueue?
    @Published public var currentSelected: UUID? = nil
    @Published public var accounts: [UUID:any MinecraftAccount] = [:]
    public var selectedAccount: any MinecraftAccount {
        return accounts[currentSelected!]!
    }
    public let clientId = "a6d48d61-71a0-45eb-8957-f6d2e760f8f6"
    public var stateCallbacks: [String: (String) -> Void] = [:]
    public var msAccountViewModel: MicrosoftAccountViewModel? = nil
    
    public init() {
        self.server = .init()
    }
    
    public func setupMicrosoftAccount(code: String) {
        print("your face is \(code)")
        
        guard let msAccountViewModel = self.msAccountViewModel else {
            return
        }
        
        Task(priority: .high) {
            do {
                let msAccessToken: MicrosoftAccessToken = try await MicrosoftAuthentication.createMsAccount(code: code, clientId: self.clientId)
                DispatchQueue.main.async {
                    msAccountViewModel.setAuthWithXboxLive()
                }
                let xblResponse = try await MicrosoftAuthentication.authenticateWithXBL(msAccessToken: msAccessToken.token)
                DispatchQueue.main.async {
                    msAccountViewModel.setAuthWithXboxXSTS()
                }
                let xstsResponse: XboxAuthResponse = try await MicrosoftAuthentication.authenticateWithXSTS(xblToken: xblResponse.token)
                DispatchQueue.main.async {
                    msAccountViewModel.setFetchingProfile()
                }
                let mcResponse: MinecraftAuthResponse = try await MicrosoftAuthentication.authenticateWithMinecraft(using: .init(xsts: xstsResponse))
                let profile: MinecraftProfile = try await MicrosoftAuthentication.getProfile(accessToken: mcResponse.accessToken)
                let account: MicrosoftAccount = .init(profile: profile, token: msAccessToken)
                self.accounts[account.id] = account
                DispatchQueue.main.async {
                    msAccountViewModel.closeSheet()
                    self.msAccountViewModel = nil
                }
            } catch let error as MicrosoftAuthError {
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
}
