//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation

public protocol BuildInfoProvider {
    var path: String? { get }
}

public enum BuildInfoError: Error {
    case canNotFindBuildInfo
    case canNotFindWorkingDirectory
    case canNotFindExportOptions
}

public extension BuildInfoProvider {
    var path: String? {
        UserDefaults.standard.value(forKey: "buildInfoPath") as? String
    }
    
    var workingDirectory: String? {
        UserDefaults.standard.value(forKey: "workingDirectory") as? String
    }
    
    var plistPath: String? {
        workingDirectory?.appending("/ExportOptions.plist")
    }
    
    func buildInfo() throws -> BuildInformation {
        guard let path = path else {
            throw BuildInfoError.canNotFindBuildInfo
        }
        return try BuildInformation.stored(atPath: path)
    }
}

public extension BuildInfoProvider {
    func archivePath() throws -> String {
        let info = try self.buildInfo()
        guard let workingDirectory = self.workingDirectory else {
            throw BuildInfoError.canNotFindWorkingDirectory
        }
        return workingDirectory.appending("/\(info.scheme).xcarchive")
    }
    
    func ipaExportPath() throws -> String {
        let info = try self.buildInfo()
        guard let workingDirectory = self.workingDirectory else {
            throw BuildInfoError.canNotFindWorkingDirectory
        }
        return workingDirectory.appending("/\(info.scheme)-archives")
    }
    
    func ipaPath() throws -> String {
        let info = try self.buildInfo()
        return try ipaExportPath().appending("/\(info.scheme).ipa")
    }
    
    func derivedDataPath() throws -> String {
        return try ipaExportPath().appending("/build-path")
    }
    
    func archiveCommands() throws -> String {
        let info = try buildInfo()
        let path = try archivePath()
        let derivedDataPath = try derivedDataPath()
        let command = [
            "xcodebuild",
            info.projectType,
            info.projectPath.wrappedInQuotes,
            "-scheme", info.scheme.wrappedInQuotes,
            "-destination generic/platform=iOS",
            "-derivedDataPath", derivedDataPath,
            "-archivePath", path.wrappedInQuotes,
            "archive"
        ].joined(separator: " ")
        return "set -o pipefail && \(command) | xcbeautify"
    }
    
    func ipaCommand() throws -> String {
        let path = try archivePath()
        let exportPath = try ipaExportPath()
        guard let plistPath = plistPath else {
            throw BuildInfoError.canNotFindExportOptions
        }
        let command = [
            "xcodebuild",
            "-exportArchive",
            "-archivePath", path.wrappedInQuotes,
            "-exportPath", exportPath.wrappedInQuotes,
            "-exportOptionsPlist", plistPath.wrappedInQuotes
        ].joined(separator: " ")
        return command
    }
}
