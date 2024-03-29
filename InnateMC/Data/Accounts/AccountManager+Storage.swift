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

extension AccountManager {
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
            var deserializedAccounts: [UUID:any MinecraftAccount] = [:]
            for (_, account) in accounts {
                let type = account["type"] as! String
                if type == "Offline" {
                    let acc = OfflineAccount.createFromDict(account)
                    deserializedAccounts[acc.id] = acc
                } else if type == "Microsoft" {
                    let acc = MicrosoftAccount.createFromDict(account)
                    deserializedAccounts[acc.id] = acc
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
        logger.debug("Loaded \(manager.accounts.count) accounts")
        
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
