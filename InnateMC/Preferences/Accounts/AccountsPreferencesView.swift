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
    
    var body: some View {
        VStack {
            Table(of: MinecraftAccount.self, selection: Binding(get: {
                return launcherData.accountManager.currentSelected
            }, set: { (a, b) in
                launcherData.accountManager.currentSelected = a ?? UUID()
            })) {
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
                launcherData.accountManager.accounts[acc.uuid] = acc
            }
        }
    }
}

struct AccountsPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        AccountsPreferencesView()
    }
}
