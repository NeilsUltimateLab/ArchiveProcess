//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import ArchiveCore
import Core

struct PrePush: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(subcommands: [Install.self, Uninstall.self])
    }
    
    func run() throws {
        try Run().run()
    }
}

extension PrePush {
    struct Install: ParsableCommand {
        func run() throws {
            let buildCode = Process.runZshCommand("swift build -c release")
            if buildCode != 0 {
                throw ProcessError.canNotBuild
            }
            let installCode = Process.runZshCommand("install .build/release/PrePush /usr/local/bin/pre-push")
            if installCode != 0 {
                throw ProcessError.canNotInstall
            }
        }
    }
    
    struct Uninstall: ParsableCommand {
        func run() throws {
            
        }
    }
}
