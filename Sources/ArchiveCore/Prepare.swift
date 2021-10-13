//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import ArgumentParser
import Core

public struct Prepare: ParsableCommand {
    public init() {}
    
    public static var configuration: CommandConfiguration {
        CommandConfiguration(subcommands: [PrepareBuildInfo.self, PrepareExportOptions.self, ClearPreviousArtifacts.self])
    }
    
    public func run() throws {
        print("> Preparing the files -------")
        try PrepareBuildInfo().run()
        try PrepareExportOptions().run()
        try ClearPreviousArtifacts().run()
    }
    
    public struct PrepareBuildInfo: ParsableCommand {
        public init() {}
        public func run() throws {
            let path = try FileManager.default.createDirectory(named: "../../ArchiveProcess-Artificats")
            print("Created the directory `ArchiveProcess-Artificats` at \(path)")
            UserDefaults.standard.setValue(path, forKey: "workingDirectory")
            
            // Create the build info placeholder if needed
            let url = URL(fileURLWithPath: path).appendingPathComponent("buildInfo.json")
            if FileManager.default.fileExists(atPath: url.path) {
                UserDefaults.standard.setValue(url.path, forKey: "buildInfoPath")
                return
            } else {
                try BuildInformation.placeholder.write(to: url)
                print("Opening buildInfo.json file. Please fill the necessary information in it.")
                let openCode = Process.runZshCommand("open . \(url)")
                if openCode != 0 {
                    throw ProcessError.canNotOpenBuildInfoFile
                }
                UserDefaults.standard.setValue(url.path, forKey: "buildInfoPath")
            }
        }
    }
    
    public struct PrepareExportOptions: ParsableCommand, BuildInfoProvider {
        public init() {}
        public func run() throws {
            print("Building the project")
            let buildInfo = try buildInfo()
            try generatePlist(from: buildInfo)
        }
        
        func generatePlist(from info: BuildInformation) throws {
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
    
    public struct ClearPreviousArtifacts: ParsableCommand, BuildInfoProvider {
        public init() {}
        public func run() throws {
            let archivePath = try archivePath()
            let exportPath = try ipaExportPath()
            try? FileManager.default.removeItem(atPath: archivePath)
            try? FileManager.default.removeItem(atPath: exportPath)
        }
    }
}
