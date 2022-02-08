//
//  File.swift
//  
//
//  Created by Neil Jain on 2/8/22.
//

import Foundation

class LogStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding
    
    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }
    
    func write(_ string: String) {
        if string.isEmpty { return }
        guard let data = string.data(using: .utf8) else { return }
        fileHandle.seekToEndOfFile()
        fileHandle.write(data)
    }
}

extension LogStream {
    static var stream: LogStream = {
        do {
            return try LogStream(FileHandle(forUpdating: logURL))
        } catch {
            print(error)
            fatalError()
        }
    }()
    
    static var logURL: URL {
        let url = URL(fileURLWithPath: ".archive_logs/build_log.log")
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        print("Storing the logs at: \(url.path)")
        return url
    }
}
