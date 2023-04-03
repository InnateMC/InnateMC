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

public class InstanceProcess: ObservableObject  {
    @Published public var process: Process = Process()
    
    public init(instance: Instance) {
        let javaExec = URL(fileURLWithPath: instance.preferences.runtime.defaultJava.getJavaExecutable())
        process.executableURL = javaExec
        var allArgs = [
            "-Xmx\(instance.preferences.runtime.maxMemory)M",
            "-Xms\(instance.preferences.runtime.minMemory)M",
            "-Djava.library.path=\(instance.getPath().appendingPathComponent("natives").path)"
        ]
        if instance.startOnFirstThread {
            allArgs.append("-XstartOnFirstThread")
        }
        let mcArgs = ArgumentProvider()
        mcArgs.clientId("todo")
        mcArgs.xuid("todo")
        mcArgs.username("")
        mcArgs.version("todo")
        mcArgs.gameDir(instance.getGamePath())
        mcArgs.assetsDir(FileHandler.assetsFolder)
        mcArgs.uuid(UUID())
        mcArgs.accessToken("")
        mcArgs.userType("todo")
        mcArgs.versionType("todo")
        mcArgs.width(720)
        mcArgs.height(450)
        allArgs.append("-cp")
        instance.appendClasspath(args: &allArgs)
        allArgs.append(instance.mainClass)
//        print(mcArgs.values)
//        print(instance.gameArguments)
        let mcArgsProcessed = mcArgs.accept(instance.gameArguments.flatMap({ $0.split(separator: " ").map { String($0) } }));
        allArgs.append(contentsOf: mcArgsProcessed)
        process.arguments = allArgs
        print(allArgs.joined(separator: " "))
        process.launch()
    }
}
