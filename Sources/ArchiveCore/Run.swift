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
    @Flag(help: "If passed then the xcodebuild console output will be send to xcbeutify else raw logs will be printed.")
    var beutify: Bool = false
    
    @Argument(help: "If passed the image path for badge overlap, it will replace the AppIcons with the new overlay composition.")
    var badgePath: String?
    
    public static var configuration: CommandConfiguration {
        CommandConfiguration(subcommands: [Reupload.self, UploadDSYMs.self])
    }
    
    public init() {}
    public mutating func run() throws {
        log(">> Running the complete process -------", with: .yellow)
        let startDate = Date()
        
        // Prepares the required path and files.
        try Prepare().run()
        
        // If badgePath is passed then add the badge to App Icons
        if let badgePath = badgePath, let projectPath = self.projectDirectory() {
            try AddBadge.parse(
                ["\(badgePath)", "\(projectPath)"]
            ).run()
        }
        
        // Archive the project
        try Archive.parse(
            beutify ? ["--beutify"] : []
        ).run()
        
        // Reset the badge if badge icon path passed.
        if let badgePath = badgePath, let projectPath = self.projectDirectory() {
            try AddBadge.parse(
                ["\(badgePath)", "\(projectPath)", "--reset"]
            ).run()
        }
        
        // Generates the IPA from the Archive Step.
        try GenerateIPA().run()
        
        // Symbolicate and upload the dSYMs to Firebase.
        try UploadDSYMs().run()
        
        // Uploads the IPA to Diawi.
        try Reupload(onCompletion: {
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: Date())
            log(">> It took \(components.hour ?? 0, color: .green)h - \(components.minute ?? 0, color: .green)m - \(components.second ?? 0, color: .green)s to complete whole process", with: .blue)
            ExecutionProfile.renderProfile()
            Foundation.exit(EXIT_SUCCESS)
        }).run()
    }
    
    private func projectDirectory() -> String? {
        try? self.basePath()
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
