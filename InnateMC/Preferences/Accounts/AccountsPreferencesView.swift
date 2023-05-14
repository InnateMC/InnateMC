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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

struct AccountsPreferencesView: View {
    @EnvironmentObject var launcherData: LauncherData
    @State var showAddOfflineSheet: Bool = false
    @StateObject var msAccountViewModel: MicrosoftAccountViewModel = .init()
    @State var cachedAccounts: [UUID:any MinecraftAccount] = [:]
    @State var cachedAccountsOnly: [AdaptedAccount] = []
    @State var selectedAccountIds: Set<UUID> = []
    
    var body: some View {
        VStack {
            Table(cachedAccountsOnly, selection: $selectedAccountIds) {
                TableColumn(i18n("name"), value: \.username)
                TableColumn(i18n("type"), value: \.type.rawValue)
                .width(max: 100)
            }
            
            HStack {
                Spacer()
                Button(i18n("add_offline")) {
                    self.showAddOfflineSheet = true
                }
                .padding()
                Button(i18n("add_microsoft")) {
                    self.msAccountViewModel.prepareAndOpenSheet(launcherData: self.launcherData)
                }
                .padding()
                Button(i18n("delete_selected")) {
                    for id in selectedAccountIds {
                        self.launcherData.accountManager.accounts.removeValue(forKey: id)
                    }
                    self.selectedAccountIds = []
                    DispatchQueue.global(qos: .utility).async {
                        self.launcherData.accountManager.saveThrow() // TODO: handle error
                    }
                }
                .disabled(self.selectedAccountIds.isEmpty)
                .padding()
                Spacer()
            }
        }
        .onAppear {
            self.cachedAccounts = launcherData.accountManager.accounts
            self.cachedAccountsOnly = Array(self.cachedAccounts.values).map({ AdaptedAccount(from: $0)})
        }
        .onReceive(launcherData.accountManager.$accounts) {
            self.cachedAccounts = $0
            self.cachedAccountsOnly = Array($0.values).map({ AdaptedAccount(from: $0)})
        }
        .onReceive(msAccountViewModel.$showMicrosoftAccountSheet, perform: {
            if !$0 {
                launcherData.accountManager.msAccountViewModel = nil
            }
        })
        .sheet(isPresented: $showAddOfflineSheet) {
            AddOfflineAccountView(showSheet: $showAddOfflineSheet) {
                let acc = OfflineAccount.createFromUsername($0)
                self.launcherData.accountManager.accounts[acc.id] = acc
                DispatchQueue.global(qos: .utility).async {
                    self.launcherData.accountManager.saveThrow() // TODO: handle error
                }
            }
        }
        .sheet(isPresented: $msAccountViewModel.showMicrosoftAccountSheet) {
            HStack {
                if msAccountViewModel.error == .noError {
                    VStack {
                        Text(msAccountViewModel.message)
                    }
                    .padding()
                } else {
                    VStack {
                        Text(msAccountViewModel.error.localizedDescription).padding()
                        Button("Close") {
                            msAccountViewModel.closeSheet()
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .frame(idealWidth: 400)
        }
    }
}

struct AccountsPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPreferencesView()
    }
}

class AdaptedAccount: Identifiable {
    var id: UUID
    var username: String
    var type: MinecraftAccountType
    
    init(from acc: any MinecraftAccount) {
        self.id = acc.id
        self.username = acc.username
        self.type = acc.type
    }
}
