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

public struct Prepare: ParsableCommand, MeasuredCommand {
    public init() {}
    
    public static var configuration: CommandConfiguration {
        CommandConfiguration(subcommands: [
            PrepareBuildInfo.self,
            PrepareExportOptions.self,
            ClearPreviousArtifacts.self,
            InstallXCPrettyIfNeeded.self
        ])
    }
    
    public func run() throws {
        try self.measure {
            log("> Preparing the files -------", with: .yellow)
            try PrepareBuildInfo().run()
            try PrepareExportOptions().run()
            try ClearPreviousArtifacts().run()
            try InstallXCbeautifyIfNeeded().run()
        }
    }
    
    public struct InstallXCPrettyIfNeeded: ParsableCommand {
        public init() {}
        
        public static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "install-xcpretty",
                abstract: "Checks for XCPretty installation in the machine. If not found it will try to install using Ruby.",
                discussion: "XCPretty outputs readable xcode logs to console. This command will check for XCPretty, if not found it will try to install using Ruby",
                helpNames: NameSpecification.shortAndLong
            )
        }
        
        public func run() throws {
            let command = """
            if which xcpretty;
            then
              echo "XCPretty is installed on the System. Good to Continue 🤞🏻"
            else
              echo "Installing XCPretty ..."
              sudo gem install xcpretty --verbose
            fi
            """
            let code = Process.runZshCommand(command)
            if code != 0 {
                throw PreparationError.invalidateXCPrettyCommand
            } else {
                log("Successfully completed Install XCPretty Step 🥳", with: .green)
            }
        }
    }
    
    public struct InstallXCbeautifyIfNeeded: ParsableCommand {
        public init() {}
        
        public static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "install-xcbeautify",
                abstract: "Checks for XCBeautify installation in the machine. If not found it will try to install using Homebrew.",
                discussion: "XCBeautify outputs readable xcode logs to console. This command will check for xcbeautify, if not found it will try to install using Homebrew.",
                helpNames: NameSpecification.shortAndLong
            )
        }
        
        public func run() throws {
            let command = """
            if which xcbeautify;
            then
              echo "xcbeautify is installed on the System. Good to Continue 🤞🏻"
            else
              echo "Installing xcbeautify ..."
              sudo brew install xcbeautify --verbose
            fi
            """
            let code = Process.runZshCommand(command)
            if code != 0 {
                throw PreparationError.invalidateXCPrettyCommand
            } else {
                log("Successfully completed Install XCBeautify Step 🥳", with: .green)
            }
        }
    }
    
    public struct PrepareBuildInfo: ParsableCommand, MeasuredCommand {
        public init() {}
        public func run() throws {
            try self.measure {
                FileManager.default.remove(at: FileManager.default.currentDirectoryPath.appending("/.archiveProcess"))
                let path = try FileManager.default.createDirectory(named: ".archiveProcess")
                log("Created the directory `archiveProcess` at \(path)", with: .green)
                UserDefaults.standard.setValue(path, forKey: "workingDirectory")
                
                let currentWorkingPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("buildInfo.json")
                
                // Create the build info placeholder if needed
                let url = URL(fileURLWithPath: path).appendingPathComponent("buildInfo.json")
                if FileManager.default.fileExists(atPath: url.path) {
                    UserDefaults.standard.setValue(url.path, forKey: "buildInfoPath")
                    return
                } else if FileManager.default.fileExists(atPath: currentWorkingPath.path) {
                    try FileManager.default.copyItem(at: URL(fileURLWithPath: currentWorkingPath.path), to: url)
                    log("Successfully copied the existing build info file.", with: .green)
                    UserDefaults.standard.setValue(url.path, forKey: "buildInfoPath")
                } else {
                    log("Can not find buildInfo.json at : \(currentWorkingPath)", with: .yellow)
                    try BuildInformation.placeholder.write(to: url)
                    log("Opening buildInfo.json file. Please fill the necessary information in it.", with: .yellow)
                    let openCode = Process.runZshCommand("open . \(url)")
                    if openCode != 0 {
                        throw ProcessError.canNotOpenBuildInfoFile
                    }
                    UserDefaults.standard.setValue(url.path, forKey: "buildInfoPath")
                }
            }
        }
    }
    
    public struct PrepareExportOptions: ParsableCommand, MeasuredCommand, BuildInfoProvider {
        public init() {}
        public func run() throws {
            try self.measure {
                log("Building the project", with: .yellow)
                let buildInfo = try buildInfo()
                try generatePlist(from: buildInfo)
            }
        }
        
        func generatePlist(from info: BuildInformation) throws {
            let currentPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("ExportOptions.plist")
            if FileManager.default.fileExists(atPath: currentPath.path) {
                try FileManager.default.copyItem(atPath: currentPath.path, toPath: plistPath!)
                log("Successfully copied the existing export options file.", with: .green)
                return
            } else {
                log("Can not find ExportOptions.plist at : \(currentPath)", with: .red)
            }
            guard let plistPath = plistPath else {
                throw ProcessError.canNotGetBuildInfo
            }
            guard let data = plistData(info: info) else {
                throw ProcessError.canNotGenerateExportOptionsPlist
            }
            FileManager.default.remove(at: plistPath)
            try data.write(to: URL(fileURLWithPath: plistPath))
        }
        
        func plistData(info: BuildInformation) -> Data? {
                """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                    <key>compileBitcode</key>
                    <\(info.exportOptionInfo.compileBitcode.text)/>
                    <key>destination</key>
                    <string>export</string>
                    <key>method</key>
                    <string>\(info.exportOptionInfo.exportMethod)</string>
                    <key>provisioningProfiles</key>
                    <dict>
                        <key>\(info.exportOptionInfo.provisioningProfiles.bundleId)</key>
                        <string>\(info.exportOptionInfo.provisioningProfiles.profileName)</string>
                    </dict>
                    <key>signingCertificate</key>
                    <string>\(info.exportOptionInfo.signingCertification)</string>
                    <key>signingStyle</key>
                    <string>manual</string>
                    <key>stripSwiftSymbols</key>
                    <true/>
                    <key>teamID</key>
                    <string>\(info.exportOptionInfo.teamId)</string>
                    <key>thinning</key>
                    <string>&lt;none&gt;</string>
                </dict>
                </plist>
                """
                .data(using: .utf8)
        }
    }
    
    public struct ClearPreviousArtifacts: ParsableCommand, MeasuredCommand, BuildInfoProvider {
        public init() {}
        public func run() throws {
            try self.measure {
                let archivePath = try archivePath()
                let exportPath = try ipaExportPath()
                try? FileManager.default.removeItem(atPath: archivePath)
                try? FileManager.default.removeItem(atPath: exportPath)
            }
        }
    }
    
    public enum PreparationError: Error {
        case invalidateXCPrettyCommand
    }
}
