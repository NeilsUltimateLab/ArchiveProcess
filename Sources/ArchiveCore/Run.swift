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
import Utilities

public struct Run: ParsableCommand, MeasuredCommand, BuildInfoProvider {
    public static var configuration: CommandConfiguration {
        CommandConfiguration(subcommands: [Reupload.self, UploadDSYMs.self])
    }
    
    public init() {}
    public mutating func run() throws {
        log(">> Running the complete process -------", with: .yellow)
        let startDate = Date()
        try Prepare().run()
        try Archive().run()
        try GenerateIPA().run()
        try UploadDSYMs().run()
        try Reupload(onCompletion: {
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
            log(">> It took \(components.hour ?? 0, color: .green)h - \(components.minute ?? 0, color: .green)m - \(components.second ?? 0, color: .green)s to complete whole process", with: .blue)
            ExecutionProfile.renderProfile()
            Foundation.exit(EXIT_SUCCESS)
        }).run()
    }
}

public extension Run {
    struct Reupload: ParsableCommand, MeasuredCommand, BuildInfoProvider {
        var onCompletion: (()->Void)?
        public init() {}
        public init(onCompletion: @escaping (()->Void)) {
            self.onCompletion = onCompletion
        }
        public func run() throws {
            try self.measure {
                log(">> Uploading to diawi -------", with: .yellow)
                let info = try self.buildInfo()
                let path = try self.ipaPath()
                let url = URL(fileURLWithPath: path)
                let file = DiawiFile(url, fileName: url.lastPathComponent, token: info.diawiToken, emails: info.callbackEmails)
                Uploader(file: file) {
                    self.onCompletion?()
                }.run()
            }
        }
        
        enum CodingKeys: CodingKey {}
    }
}
