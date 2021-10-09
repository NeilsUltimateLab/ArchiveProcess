//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Core

public struct Archive: ParsableCommand, BuildInfoProvider {
    public init() {}
    public func run() throws {
        print(">> Archiving the project -------")
        let archiveCommand = try self.archiveCommands()
        let code = Process.runZshCommand(archiveCommand)
        if code != 0 {
            throw ProcessError.canNotGenerateArchive
        }
        print(">> Archive Generated successfully! 🎉")
    }
}
