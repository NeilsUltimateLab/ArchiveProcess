//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import Utilities
import ArgumentParser
import Core

public struct Archive: ParsableCommand, MeasuredCommand, BuildInfoProvider {
    public init() {}
    public func run() throws {
        try self.measure {
            log(">> Archiving the project -------", with: .yellow)
            let archiveCommand = try self.archiveCommands()
            let code = Process.runZshCommand(archiveCommand)
            if code != 0 {
                throw ProcessError.canNotGenerateArchive
            }
            log(">> Archive Generated successfully! 🎉", with: .green)
        }
    }
}
