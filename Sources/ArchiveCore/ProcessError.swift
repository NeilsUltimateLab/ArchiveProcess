//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation

public enum ProcessError: Error {
    case canNotBuild
    case canNotInstall
    case canNotUninstall
    case canNotOpenBuildInfoFile
    case canNotGetBuildInfo
    case canNotGenerateExportOptionsPlist
    case canNotGenerateArchive
    case canNotGenerateIPA
}
