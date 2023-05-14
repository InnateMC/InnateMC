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

public class InstanceProcess: ObservableObject  {
    @Published public var process: Process = Process()
    @Published public var terminated = false
    @Published public var logMessages: [String] = []
    
    init(instance: Instance, account: any MinecraftAccount) {
        var maxMemory = setting(\.runtime.maxMemory)
        var minMemory = setting(\.runtime.minMemory)
        var javaInstallation = setting(\.runtime.defaultJava)
        if instance.preferences.runtime.valid {
            maxMemory = setting(\.runtime.maxMemory, for: instance)
            minMemory = setting(\.runtime.minMemory, for: instance)
            javaInstallation = setting(\.runtime.defaultJava, for: instance)
        }
        let javaExec = URL(fileURLWithPath: javaInstallation.javaExecutable)
        process.executableURL = javaExec
        var allArgs = [
            "-Xmx\(maxMemory)M",
            "-Xms\(minMemory)M",
            "-Djava.library.path=\(instance.getPath().appendingPathComponent("natives").path)"
        ]
        if instance.startOnFirstThread {
            allArgs.append("-XstartOnFirstThread")
        }
        let mcArgs = ArgumentProvider()
        mcArgs.clientId("todo")
        mcArgs.xuid("todo")
        mcArgs.username(account.username)
        mcArgs.version("todo")
        mcArgs.gameDir(instance.getGamePath())
        mcArgs.assetsDir(FileHandler.assetsFolder)
        mcArgs.assetIndex(instance.assetIndex.id)
        mcArgs.uuid(account.id)
        mcArgs.accessToken("todo")
        mcArgs.userType("todo")
        mcArgs.versionType("todo")
        mcArgs.width(720)
        mcArgs.height(450)
        allArgs.append("-cp")
        instance.appendClasspath(args: &allArgs)
        allArgs.append(instance.mainClass)
        let mcArgsProcessed = mcArgs.accept(instance.gameArguments.flatMap({ $0.split(separator: " ").map { String($0) } }));
        allArgs.append(contentsOf: mcArgsProcessed)
        process.arguments = allArgs
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        let outputHandler = outputPipe.fileHandleForReading
        outputHandler.readabilityHandler = { [weak self] pipe in
            guard let line = String(data: pipe.availableData, encoding: .utf8)?.trimmingCharacters(in: .newlines) else {
                return
            }
            DispatchQueue.main.async {
                self?.logMessages.append(line)
            }
        }
        
        DispatchQueue.global(qos: .utility).async {
            self.process.launch()
            self.process.waitUntilExit()
            DispatchQueue.main.async {
                self.terminated = true
            }
        }
        
        logMessages.append("InnateMC: Launching Instance \(instance.name)")
    }
}

fileprivate extension Process {
    func getRunCommand() -> String {
        var command = self.launchPath ?? ""
        
        if let arguments = self.arguments {
            for arg in arguments {
                command += " \(arg)"
            }
        }
        
        return command
    }
}
