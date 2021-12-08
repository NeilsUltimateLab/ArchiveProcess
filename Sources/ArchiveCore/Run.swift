//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Core
import Uploader

public struct Run: ParsableCommand, BuildInfoProvider {
    public static var configuration: CommandConfiguration {
        CommandConfiguration(subcommands: [Reupload.self])
    }
    
    public init() {}
    public func run() throws {
        print(">> Running the complete process -------")
        let startDate = Date()
        try Prepare().run()
        try Archive().run()
        try GenerateIPA().run()
        try Reupload().run()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
        print(">> It took \(components.hour ?? 0)h - \(components.minute ?? 0)m - \(components.second ?? 0)s to complete whole process")
    }
}

public extension Run {
    struct Reupload: ParsableCommand, BuildInfoProvider {
        public init() {}
        public func run() throws {
            print(">> Uploading to diawi -------")
            let info = try self.buildInfo()
            let path = try self.ipaPath()
            let url = URL(fileURLWithPath: path)
            let file = DiawiFile(url, fileName: url.lastPathComponent, token: info.diawiToken, emails: info.callbackEmails)
            Uploader(file: file).run()
        }
    }
}
