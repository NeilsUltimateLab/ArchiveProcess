//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArchiveCore
import ArgumentParser

extension ArchiveProcess {
    struct PrePush: ParsableCommand {
        func run() throws {
            let url = URL(fileURLWithPath: "/usr/local/bin/PrePush")
            if FileManager.default.fileExists(atPath: url.path) {
                let installCode = Process.runZshCommand("cp /usr/local/bin/PrePush .git/hooks/pre-push")
                if installCode != 0 {
                    throw ProcessError.canNotInstall
                }
            } else {
                print("pre-push is not installed")
            }
        }
    }
}
