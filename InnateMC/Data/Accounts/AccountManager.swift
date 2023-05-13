//
// Copyright © 2022 Shrish Deshpande
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

class AccountManager: ObservableObject {
    public static let accountsPath: URL = try! FileHandler.getOrCreateFolder().appendingPathComponent("Accounts.plist")
    public static let plistEncoder = PropertyListEncoder()
    private let authUrl: URL
    private let server: HttpServer
    private let serverThread: DispatchQueue
    @Published public var currentSelected: UUID? = nil
    @Published public var accounts: [UUID:MinecraftAccount] = [:]
    public var selectedAccount: MinecraftAccount {
        return accounts[currentSelected!]!
    }
    
    public init() {
        let baseURL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize"
        
        var urlComponents: URLComponents = .init(string: baseURL)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: "a6d48d61-71a0-45eb-8957-f6d2e760f8f6"),
            URLQueryItem(name: "redirect_uri", value: "http://localhost:1989"),
            URLQueryItem(name: "scope", value: "XboxLive.signin"),
            URLQueryItem(name: "state", value: "nou")
        ]
        
        self.authUrl = urlComponents.url!
        
        self.server = .init()
        self.server["/"] = { request in
            if let code = request.queryParams.first(where: { $0.0 == "code" })?.1 {
                return HttpResponse.ok(.text("<html><body>Code value: \(code)</body></html>"))
            } else {
                return HttpResponse.badRequest(nil)
            }
        }
        
        self.serverThread = .init(label: "server")
        
        self.serverThread.async {
            do {
                try self.server.start(1989)
                NSLog("Started authentication handler server")
            } catch {
                NSLog("Error starting authentication handler server - adding microsoft account support is limited")
            }
        }
    }
    
    public func createAuthWindow() -> WebViewWindow {
        return .init(url: self.authUrl)
    }
    
    public static func load() throws -> AccountManager {
        let manager = AccountManager()
        
        // TODO: error handling
        if let data = try FileHandler.getData(AccountManager.accountsPath) {
            let plist: [String:Any] = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
            var currentSelected: UUID? = nil
            if let currentSelectedE = plist["Current"] as? String {
                currentSelected = UUID(uuidString: currentSelectedE)!
            }
            let accounts = plist["Accounts"] as! [String:[String:Any]]
            var deserializedAccounts: [UUID:MinecraftAccount] = [:]
            for (_, account) in accounts {
                let type = account["type"] as! String
                if type == "Offline" {
                    let acc = OfflineAccount.createFromDict(account)
                    deserializedAccounts[acc.uuid] = acc
                } else if type == "Microsoft" {
                    // TODO: implement
                }
            }
            if let e = currentSelected {
                if !deserializedAccounts.keys.contains(e) {
                    currentSelected = nil
                }
            }
            manager.currentSelected = currentSelected
            manager.accounts = deserializedAccounts
        }
        
        return manager
    }
    
    public func saveThrow() {
        var plist: [String:Any] = [:]
        if let currentSelected = currentSelected {
            plist["Current"] = currentSelected.uuidString
        }
        var accounts: [String:Any] = [:]
        for (thing, account) in self.accounts {
            accounts[thing.uuidString] = try! PropertyListSerialization.propertyList(from: try! AccountManager.plistEncoder.encode(account), format: nil)
        }
        plist["Accounts"] = accounts
        try! FileHandler.saveData(AccountManager.accountsPath, PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0))
    }
}
