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

extension Instance {
    public func getLibrariesAsTasks() -> [DownloadTask] {
        var tasks: [DownloadTask] = []
        for library in libraries {
            if library.type == .local {
                continue
            }
            tasks.append(library.asDownloadTask())
        }
        if (self.minecraftJar.type == .remote) {
            tasks.append(DownloadTask(sourceUrl: URL(string: self.minecraftJar.url!)!, filePath: self.getMcJarPath(), sha1: self.minecraftJar.sha1))
        }
        return tasks
    }    
    
    public func appendClasspath(args: inout [String]) {
        let libString = self.libraries.map { lib in
            return lib.getAbsolutePath().path
        }.joined(separator: ":")
        args.append("\(getMcJarPath().path):\(libString)");
        //        args.append("\(getMcJarPath().path)") // DEBUG
    }
    
    public func extractNatives(progress: TaskProgress) {
        if !FileManager.default.fileExists(atPath: getNativesPath().path) {
            try! FileManager.default.createDirectory(at: getNativesPath(), withIntermediateDirectories: true)
        }
        let nativeLibraries = self.libraries.filter { $0.path.contains("natives") }
        var extractTasks: [() -> Void] = []
        for nativeLibrary in nativeLibraries {
            extractTasks.append {
                let nativeLibraryPath = nativeLibrary.getAbsolutePath()
                Instance.extractNativesFrom(library: nativeLibraryPath, output: self.getNativesPath())
            }
        }
        ParallelExecutor.run(extractTasks, progress: progress)
    }
    
    private static func extractNativesFrom(library input: URL, output: URL) {
        let inputStr = input.path
        var zip_file: OpaquePointer?
        var file: OpaquePointer?
        var stat = zip_stat()
        
        zip_file = zip_open(inputStr, 0, nil)
        if zip_file == nil {
            print("Failed to open zip file \(inputStr)")
            return
        }
        
        let num_files = Int(zip_get_num_files(zip_file!))
        for i in 0..<num_files {
            zip_stat_init(&stat)
            zip_stat_index(zip_file!, zip_uint64_t(Int32(i)), 0, &stat)
            
            let filename = String(cString: stat.name!)
            if let ext = filename.split(separator: ".").last,
               (ext == "dylib" || ext == "jnilib") {
                
                let output_filename = output.appendingPathComponent(filename).path
                
                file = zip_fopen_index(zip_file!, zip_uint64_t(Int32(i)), 0)
                if file == nil {
                    print("Failed to open file \(filename) in zip")
                    continue
                }
                
                guard let output_file = fopen(output_filename, "wb") else {
                    print("Failed to create output file \(output_filename)")
                    zip_fclose(file!)
                    continue
                }
                
                let buffer_size = 1024
                var buffer = [UInt8](repeating: 0, count: buffer_size)
                var num_bytes = 0
                repeat {
                    num_bytes = Int(zip_fread(file!, &buffer, zip_uint64_t(buffer_size)))
                    fwrite(buffer, 1, num_bytes, output_file)
                } while num_bytes > 0
                
                fclose(output_file)
                zip_fclose(file!)
            }
        }
    }
    
    public func downloadLibs(progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (ParallelDownloadError) -> Void) -> URLSession {
        let tasks = getLibrariesAsTasks()
        return ParallelDownloader.download(tasks, progress: progress, onFinish: onFinish, onError: onError)
    }
    
    public func downloadAssets(progress: TaskProgress, onFinish: @escaping () -> Void, onError: @escaping (ParallelDownloadError) -> Void) -> URLSession? {
        var index: AssetIndex
        do {
            index = try AssetIndex.get(version: self.assetIndex.id, urlStr: self.assetIndex.url)
        } catch {
            onError(ParallelDownloadError.downloadFailed(errorKey: "error_downloading"))
            return nil
        }
        return index.downloadParallel(progress: progress, onFinish: onFinish, onError: onError)
    }
}
