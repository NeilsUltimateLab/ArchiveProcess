import Foundation
import ArgumentParser
import Core
import Uploader
import ArchiveCore

struct ArchiveProcess: ParsableCommand {
    
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            version: "1.0.5",
            subcommands: [
                Install.self,
                Uninstall.self,
                Release.self,
                Run.self,
                Prepare.self,
                AddBadge.self,
                Archive.self,
                GenerateIPA.self,
                UploadToDiawi.self
            ],
            defaultSubcommand: Install.self
        )
    }
    
    func run() throws {
        try Install().run()
    }
    
}


