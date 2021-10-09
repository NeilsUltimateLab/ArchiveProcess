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
        print("\n>> Uplading to Diawi -------")
        let file = DiawiFile(url, fileName: fileName, token: token, emails: emails)
        print("Created the uploader, file: \(file)")
        Uploader(file: file).run()
    }
}
