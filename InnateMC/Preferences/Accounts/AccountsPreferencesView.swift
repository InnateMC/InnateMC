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
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI

struct AccountsPreferencesView: View {
    @EnvironmentObject var launcherData: LauncherData
    @State var showAddOfflineSheet: Bool = false
    @State var cachedAccounts: [UUID:MinecraftAccount] = [:]
    @State var selectedAccountIds: Set<UUID> = []
    
    var body: some View {
        VStack {
            Table(of: MinecraftAccount.self, selection: $selectedAccountIds) {
                TableColumn(i18n("name"), value: \.username)
                TableColumn(i18n("type"), value: \.strType)
                .width(max: 100)
            } rows: {
                ForEach(Array(cachedAccounts.values)) { account in
                    TableRow(account)
                }
            }
            .padding()
            HStack {
                Spacer()
                Button(i18n("add_offline")) {
                    self.showAddOfflineSheet = true
                }
                .padding()
                Button(i18n("add_microsoft")) {
                    print("no")
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
                .disabled(selectedAccountIds.isEmpty)
                .padding()
                Spacer()
            }
        }
        .onAppear {
            self.cachedAccounts = launcherData.accountManager.accounts
        }
        .onReceive(launcherData.accountManager.$accounts) {
            self.cachedAccounts = $0
        }
        .sheet(isPresented: $showAddOfflineSheet) {
            AddOfflineAccountView(showSheet: $showAddOfflineSheet) {
                let acc = OfflineAccount.createFromUsername($0)
                self.launcherData.accountManager.accounts[acc.uuid] = acc
                DispatchQueue.global(qos: .utility).async {
                    self.launcherData.accountManager.saveThrow() // TODO: handle error
                }
            }
        }
    }
}

struct AccountsPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPreferencesView()
    }
}
