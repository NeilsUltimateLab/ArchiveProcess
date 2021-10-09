//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation

public struct BuildInformation: Codable {
    public var projectType: String = "-project"
    public var projectPath: String
    public var scheme: String
    public var exportOptionInfo: ExportOptionInformation
    public var diawiToken: String
    public var callbackEmails: String
}

public extension BuildInformation {
    static var placeholder: BuildInformation {
        BuildInformation(
            projectType: "-project",
            projectPath: "<#Project.xcproj>",
            scheme: "<#ProjectScheme>",
            exportOptionInfo: .placeholder,
            diawiToken: "<#DIAWI-Token>",
            callbackEmails: "<#email1@address.com>,<#email2@address.com>"
        )
    }
}

public struct ExportOptionInformation: Codable {
    public var compileBitcode: Bool = true
    public var exportMethod: String = "development"
    public var provisioningProfiles: ProvisioningProfile
    public var signingCertification: String = "Apple Development"
    public var teamId: String
}

public extension ExportOptionInformation {
    static var placeholder: ExportOptionInformation {
        ExportOptionInformation(
            compileBitcode: true,
            exportMethod: "development",
            provisioningProfiles: .placeholder,
            signingCertification: "<#Apple Development>",
            teamId: "<#Team-ID>"
        )
    }
}

public struct ProvisioningProfile: Codable {
    public var bundleId: String = "<#BundleId>"
    public var profileName: String = "<#ProfileName>"
}

public extension ProvisioningProfile {
    static var placeholder: ProvisioningProfile {
        ProvisioningProfile()
    }
}

public extension Bool {
    var text: String {
        self ? "true" : "false"
    }
}

