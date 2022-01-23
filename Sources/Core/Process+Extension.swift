//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation

public extension Process {
    
    @discardableResult
    static func runZshCommand(_ command: String) -> Int32 {
        let process = Process()
        process.launchPath = "/bin/zsh"
        process.arguments = ["-c", command]
        print("Running command -----\n\(command.colorised(to: .green))")
        
        process.standardOutput = {
            let pipe = Pipe()
            pipe.fileHandleForReading.readabilityHandler = { handler in
                guard let string = String(data: handler.availableData, encoding: .utf8), string.isEmpty == false else {
                    return
                }
                print(string.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return pipe
        }()
        
        process.standardError = {
            let pipe = Pipe()
            pipe.fileHandleForReading.readabilityHandler = { handler in
                guard let string = String(data: handler.availableData, encoding: .utf8), string.isEmpty == false else {
                    return
                }
                print(string.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            return pipe
        }()
        
        process.launch()
        process.waitUntilExit()
        (process.standardError as? Pipe)?.fileHandleForReading.readabilityHandler = nil
        (process.standardOutput as? Pipe)?.fileHandleForReading.readabilityHandler = nil
        
        return process.terminationStatus
    }
    
}

extension String {
    enum OutputColor: String {
        case black = "30"
        case red = "31"
        case green = "32"
        case yellow = "33"
        case blue = "34"
        case pink = "35"
        case cyan = "36"
        case gray = "37"
        case white = "38"
        case backgroundBlack = "40"
        case backgroundBed = "41"
        case backgroundBreen = "42"
        case backgroundBellow = "43"
        case backgroundBlue = "44"
        case backgroundBink = "45"
        case backgroundByan = "46"
        case backgroundBray = "47"
    }
    func colorised(to color: OutputColor = .black) -> String {
        "\\e[1;\(color.rawValue)m \(self) \\e[0m"
    }
}
