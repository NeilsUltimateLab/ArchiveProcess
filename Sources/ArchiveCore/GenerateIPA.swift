//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Core
import Utilities

/// Generates the IPA from the build archive.
public struct GenerateIPA: ParsableCommand, MeasuredCommand, BuildInfoProvider {
    public init() {}
    
    public func run() throws {
        try self.measure {
            log(">> Generating IPA from Archive ------", with: .yellow)
            let ipaCommand = try self.ipaCommand()
            try Process.runAndThrow(ipaCommand, error: ProcessError.canNotGenerateIPA)
            let path = try self.ipaPath()
            UserDefaults.standard.set(path, forKey: "ipaPath")
            log(">> IPA Generated successfully! 🎉", with: .green)
        }
    }
}
