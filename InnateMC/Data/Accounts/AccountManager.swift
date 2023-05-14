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
}
