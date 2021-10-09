//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Core

public struct GenerateIPA: ParsableCommand, BuildInfoProvider {
    public init() {}
    public func run() throws {
        print(">> Generating IPA from Archive ------")
        let ipaCommand = try self.ipaCommand()
        let code = Process.runZshCommand(ipaCommand)
        if code != 0 {
            throw ProcessError.canNotGenerateIPA
        }
        let path = try self.ipaPath()
        UserDefaults.standard.set(path, forKey: "ipaPath")
        print(">> IPA Generated successfully! 🎉")
    }
}
