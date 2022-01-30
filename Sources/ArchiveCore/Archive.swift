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
    
    @Flag(help: "Beutify the xcodebuild output using XCBeautify, if false is passed, xcodebuild raw output will be delivered. Defaults to false.")
    var beutify: Bool = false
    
    public init(beutify: Bool = false) {
        self._beutify = Flag(wrappedValue: beutify)
    }
    
    public func run() throws {
        try self.measure {
            log(">> Archiving the project -------", with: .yellow)
            let archiveCommand = try self.archiveCommands(beutify: beutify)
            let code = Process.runZshCommand(archiveCommand)
            if code != 0 {
                throw ProcessError.canNotGenerateArchive
            }
            log(">> Archive Generated successfully! 🎉", with: .green)
        }
    }
}
