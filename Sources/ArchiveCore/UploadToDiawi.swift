//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Uploader
import Core
import Utilities

public struct UploadToDiawi: ParsableCommand {
    public init() {}
    
    @Argument
    public var ipaPath: String
    @Argument
    public var token: String
    @Argument
    public var emails: String
    
    enum CodingKeys: String, CodingKey {
        case ipaPath, token, emails
    }
    
    private var uploader = DiawiUploader()
    
    var url: URL {
        URL(fileURLWithPath: ipaPath)
    }
    
    var fileName: String {
        url.lastPathComponent
    }
    
    public func run() throws {
        log("\n>> Uplading to Diawi -------", with: .yellow)
        let file = DiawiFile(url, fileName: fileName, token: token, emails: emails)
        log("Created the uploader, file: \(file, color: .blue)", with: .yellow)
        Uploader(file: file).run()
    }
}
