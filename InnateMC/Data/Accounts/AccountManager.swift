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
import CryptoKit
import Alamofire

class AccountManager: ObservableObject {
    public static let accountsPath: URL = try! FileHandler.getOrCreateFolder().appendingPathComponent("Accounts.plist")
    public static let plistEncoder = PropertyListEncoder()
    private let server: HttpServer
    private var serverThread: DispatchQueue?
    @Published public var currentSelected: UUID? = nil
    @Published public var accounts: [UUID:MinecraftAccount] = [:]
    public var selectedAccount: MinecraftAccount {
        return accounts[currentSelected!]!
    }
    public let clientId = "a6d48d61-71a0-45eb-8957-f6d2e760f8f6"
    public var stateCallbacks: [String: (String) -> Void] = [:]
    public var msAccountViewModel: MicrosoftAccountViewModel? = nil
    
    public init() {
        self.server = .init()
    }
    
    public func setupForAuth() {
        self.serverThread = .init(label: "server")
        
        self.server["/"] = { request in
            if let code = request.queryParams.first(where: { $0.0 == "code" })?.1 {
                if let state = request.queryParams.first(where: { $0.0 == "state" })?.1 {
                    DispatchQueue.global().async {
                        self.stateCallbacks[state](code)
                    }
                } else {
                    return HttpResponse.badRequest(nil)
                }
                return HttpResponse.ok(.text("<html><body>\(code)</body></html>"))
            } else {
                return HttpResponse.badRequest(nil)
            }
        }
        
        self.serverThread?.async {
            do {
                try self.server.start(1989)
            } catch {
                NSLog("Error starting redirect handler server - adding microsoft account support is limited")
            }
        }
    }
    
    public func createAuthWindow() -> WebViewWindow {
        let baseURL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize"
        var urlComponents: URLComponents = .init(string: baseURL)!
        let state = self.state()
        
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: self.clientId),
            URLQueryItem(name: "redirect_uri", value: "http://localhost:1989"),
            URLQueryItem(name: "scope", value: "XboxLive.signin offline_access"),
            URLQueryItem(name: "state", value: state)
        ]
        
        let authUrl = urlComponents.url!
        let window: WebViewWindow = .init(url: authUrl)
        self.stateCallbacks[state] = createMsAccount
        return window
    }
    
    private func createMsAccount(_ msCode: String) {
        let msParameters: Parameters = [
            "client_id": self.clientId,
            "scope": "XboxLive.signin offline_access",
            "code": msCode,
            "redirect_uri": "http://localhost:1989",
            "grant_type": "authorization_code"
        ]
        
        AF.request("https://login.microsoftonline.com/consumers/oauth2/v2.0/token",
                   method: .post,
                   parameters: msParameters,
                   encoding: URLEncoding.default)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let token: MicrosoftAccessToken
                    do {
                        token = try MicrosoftAccessToken.fromJson(json: data)
                        
                        let xboxLiveParameters = XboxLiveAuth.fromToken(token.token)
                        let headers: HTTPHeaders = [
                            "Content-Type": "application/json",
                            "Accept": "application/json"
                        ]

                        AF.request("https://user.auth.xboxlive.com/user/authenticate", method: .post, parameters: xboxLiveParameters, encoder: JSONParameterEncoder.default, headers: headers)
                            .validate(statusCode: 200..<300)
                            .responseData { response in
                                switch response.result {
                                case .success(let data):
                                    print(data)
                                case .failure(_):
                                    DispatchQueue.main.async {
                                        self.msAccountViewModel?.error = .couldNotAuthenticateWithXboxLive
                                    }
                                }
                            }
                    } catch {
                        DispatchQueue.main.async {
                            self.msAccountViewModel?.error = .couldNotAuthenticateWithMicrosoft
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.msAccountViewModel?.setAuthWithXboxLive()
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.msAccountViewModel?.error = .couldNotFetchMicrosoftTOken
                    }
                }
            }
    }
    
    func state() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomBytes = (0..<24).map { _ in UInt8.random(in: 0..<UInt8.max) }
        let randomData = Data(randomBytes)
        let randomString = randomData.base64EncodedString()
            .filter { characters.contains($0) }
            .prefix(24)
        return String(randomString)
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
