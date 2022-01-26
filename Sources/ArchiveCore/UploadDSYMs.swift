//
//  File.swift
//  
//
//  Created by Neil Jain on 1/26/22.
//

import ArgumentParser
import Core
import Foundation
import Utilities

struct UploadDSYMs: ParsableCommand, MeasuredCommand, BuildInfoProvider {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "upload-dSYMs")
    }
    
    enum UploadSymbolError: Error {
        case uploadFailed
    }
    
    func run() throws {
        try self.measure {
            log("Starting Upload DSYMs to Firebase step.", with: .default)

            let archivePath = try archivePath()
            let derivedDataPath = try derivedDataPath()
            guard let googlePlistPath = googlePlistPath(from: archivePath) else {
                log("Could not find the GoogleService-Info.plist file so returning from UploadDSYMs step.", with: .yellow)
                return
            }
            log("Found path for GoogleService-Info.plist: \(googlePlistPath)", with: .green)
            guard let uploadScriptPath = uploadSymbolsPath(from: derivedDataPath) else {
                log("Could not find the Upload-Symbol script file so returning from UploadDSYMs step.", with: .yellow)
                return
            }
            log("Found path for Upload-Symbols path: \(uploadScriptPath)", with: .green)
            
            guard let dSYMsPath = dSYMsPath(from: archivePath) else {
                return
            }
            
            log("Found path for Generated Debug Symbols path: \(uploadScriptPath)", with: .green)
            
            log(table: "Upload dSYMs Paths", [
                ("GoogleService-Info.plist Path", googlePlistPath),
                ("Upload Script Path", uploadScriptPath),
                ("dSYMs Path", dSYMsPath)
            ])
            
            let code = Process.runZshCommand(uploadScriptCommand(uploadScriptPath: uploadScriptPath, googlePlistPath: googlePlistPath, symbolPath: dSYMsPath))
            if code != 0 {
                throw UploadSymbolError.uploadFailed
            }
        }
    }
    
    private func googlePlistPath(from root: String) -> String? {
        let rootURL = URL(fileURLWithPath: root)
        if let enumarator = FileManager.default.enumerator(atPath: root) {
            for case let path as String in enumarator {
                if path.hasSuffix("GoogleService-Info.plist") {
                    return URL(fileURLWithPath: path, relativeTo: rootURL).path
                }
            }
        }
        return nil
    }
    
    private func dSYMsPath(from root: String) -> String? {
        let rootURL = URL(fileURLWithPath: root)
        if let enumarator = FileManager.default.enumerator(atPath: root) {
            for case let path as String in enumarator {
                if path.hasSuffix("dSYMs") {
                    return URL(fileURLWithPath: path, relativeTo: rootURL).path
                }
            }
        }
        return nil
    }
    
    private func uploadSymbolsPath(from root: String) -> String? {
        let rootURL = URL(fileURLWithPath: root)
        if let enumarator = FileManager.default.enumerator(atPath: root) {
            for case let path as String in enumarator {
                if path.hasSuffix("upload-symbols") {
                    return URL(fileURLWithPath: path, relativeTo: rootURL).path
                }
            }
        }
        return nil
    }
    
    private func uploadScriptCommand(uploadScriptPath: String, googlePlistPath: String, symbolPath: String) -> String {
        """
        \(uploadScriptPath) -gsp \(googlePlistPath) -p ios \(symbolPath) -d
        """
    }
}
