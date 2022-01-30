//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Core
import ArchiveCore
import Utilities

extension ArchiveProcess {
    struct Install: ParsableCommand {
        func run() throws {
            try Process.runAndThrow(
                "swift build -c release",
                error: ProcessError.canNotBuild
            )
            try Process.runAndThrow(
                "install .build/release/ArchiveProcess /usr/local/bin/ArchiveProcess",
                error: ProcessError.canNotInstall
            )
            log("Congratulations 🥳! `ArchiveProcess-\(ArchiveProcess.configuration.version)` is installed in your machine successfully. 🎉", with: .green)
        }
    }
    
    struct Uninstall: ParsableCommand {
        func run() throws {
            try Process.runAndThrow(
                "rm -f /usr/local/bin/ArchiveProcess",
                error: ProcessError.canNotUninstall
            )
        }
    }
}
