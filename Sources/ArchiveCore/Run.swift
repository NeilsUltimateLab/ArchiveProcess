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
    public init() {}
    public func run() throws {
        print(">> Running the complete process -------")
        try Prepare().run()
        try Archive().run()
        try GenerateIPA().run()
        try upload()
    }
    
    func upload() throws {
        print(">> Uploading to diawi -------")
        let info = try self.buildInfo()
        let path = try self.ipaPath()
        let url = URL(fileURLWithPath: path)
        let file = DiawiFile(url, fileName: url.lastPathComponent, token: info.diawiToken, emails: info.callbackEmails)
        Uploader(file: file).run()
    }
}
