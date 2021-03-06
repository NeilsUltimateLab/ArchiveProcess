//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation
import Utilities

public extension Process {
    
    @discardableResult
    private static func runZshCommand(_ command: String) -> Int32 {
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        log("Running command: \n----------\n\(command, color: .green)\n----------", with: .cyan)
        
        process.standardOutput = {
            let pipe = Pipe()
            pipe.fileHandleForReading.readabilityHandler = { handler in
                guard let string = String(data: handler.availableData, encoding: .utf8), string.isEmpty == false else {
                    return
                }
                log(string.trimmingCharacters(in: .whitespacesAndNewlines), with: .default)
            }
            return pipe
        }()
        
        process.standardError = {
            let pipe = Pipe()
            pipe.fileHandleForReading.readabilityHandler = { handler in
                guard let string = String(data: handler.availableData, encoding: .utf8), string.isEmpty == false else {
                    return
                }
                log(string.trimmingCharacters(in: .whitespacesAndNewlines), with: .yellow)
            }
            return pipe
        }()
        
        process.launch()
        process.waitUntilExit()
        (process.standardError as? Pipe)?.fileHandleForReading.readabilityHandler = nil
        (process.standardOutput as? Pipe)?.fileHandleForReading.readabilityHandler = nil
        
        return process.terminationStatus
    }
    
    @discardableResult
    static func runAndThrow<CommandError>(_ command: String, error: CommandError) throws -> Int32 where CommandError: Error {
        let code = self.runZshCommand(command)
        if code != 0 {
            throw error
        } else {
            return code
        }
    }
}
