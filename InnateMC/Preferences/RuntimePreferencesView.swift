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

struct RuntimePreferencesView: View {
    @EnvironmentObject var launcherData: LauncherData
    @State var cachedDefaultJava: SavedJavaInstallation = SavedJavaInstallation.systemDefault
    @State var showFileImporter: Bool = false

    var body: some View {
        VStack {
            Form {
                Text(cachedDefaultJava.javaExecutable)
                    .frame(alignment: .center)
                    .foregroundColor(.secondary)
                TextField(i18n("default_min_mem"), value: $launcherData.globalPreferences.runtime.minMemory, formatter: NumberFormatter())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField(i18n("default_max_mem"), value: $launcherData.globalPreferences.runtime.maxMemory, formatter: NumberFormatter())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField(i18n("default_java_args"), text: $launcherData.globalPreferences.runtime.javaArgs)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .onAppear {
                self.cachedDefaultJava = launcherData.globalPreferences.runtime.defaultJava
            }
            .onReceive(launcherData.globalPreferences.runtime.$defaultJava, perform: {
                self.cachedDefaultJava = $0
                logger.debug("Default java runtime changed to \($0.javaExecutable)")
            })
            .padding([.leading, .trailing, .top], 16.0)
            .padding(.bottom, 5)
            Table(of: SavedJavaInstallation.self, selection: Binding(get: {
                return launcherData.globalPreferences.runtime.defaultJava
            }, set: {
                launcherData.globalPreferences.runtime.defaultJava = $0 ?? SavedJavaInstallation.systemDefault
            })) {
                TableColumn("Version") {
                    Text($0.getDebugString())
                }
                .width(max: 200)
                TableColumn("Path", value: \.javaExecutable)
            } rows: {
                TableRow(SavedJavaInstallation.systemDefault)
                ForEach(launcherData.javaInstallations) {
                    TableRow($0)
                }
            }
            .padding([.leading, .trailing, .bottom])
            .padding(.top, 4)
            Button(i18n("add_java_version")) {
                showFileImporter = true
            }
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.unixExecutable, .executable, .exe]) { result in
                let url: URL
                do {
                    url = try result.get()
                } catch {
                    logger.error("Error importing java runtime: \(error.localizedDescription)")
                    return
                }
                
                let install: SavedJavaInstallation = .init(javaExecutable: url.path)
                install.setupAsNewVersion(launcherData: launcherData)
                logger.info("Set up java runtime from \(install.javaExecutable)")
            }
        }
    }
}

struct PickableJavaVersion: View {
    let installation: SavedJavaInstallation
    
    var body: some View {
        Text(installation.getString())
            .tag(installation)
    }
}

struct RuntimePreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        RuntimePreferencesView()
    }
}
