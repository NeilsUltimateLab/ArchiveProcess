import Foundation
import ArgumentParser
import Core
import Uploader
import ArchiveCore

struct ArchiveProcess: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            subcommands: [
                Install.self,
                Uninstall.self,
                Run.self,
                Prepare.self,
                Archive.self,
                GenerateIPA.self,
                UploadToDiawi.self,
                PrePush.self
            ],
            defaultSubcommand: Install.self
        )
    }
    
    func run() throws {
        try Install().run()
    }
    
}


