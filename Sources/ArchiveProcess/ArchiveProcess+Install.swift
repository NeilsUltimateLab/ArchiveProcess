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
            let releaseCode = Process.runZshCommand("swift build -c release")
            if releaseCode != 0 {
                throw ProcessError.canNotBuild
            }
            let installCode = Process.runZshCommand("install .build/release/ArchiveProcess /usr/local/bin/ArchiveProcess")
            if installCode != 0 {
                throw ProcessError.canNotInstall
            }
            let prepushCode = Process.runZshCommand("install .build/release/PrePush /usr/local/bin/PrePush")
            if prepushCode != 0 {
                throw ProcessError.canNotInstall
            }
            log("Congratulations 🥳! `ArchiveProcess-\(ArchiveProcess.configuration.version)` is installed in your machine successfully. 🎉", with: .green)
        }
    }
    
    struct Uninstall: ParsableCommand {
        func run() throws {
            let uninstallCode = Process.runZshCommand("rm -f /usr/local/bin/ArchiveProcess")
            if uninstallCode != 0 {
                throw ProcessError.canNotUninstall
            }
        }
    }
}
