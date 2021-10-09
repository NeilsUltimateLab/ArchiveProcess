//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation
import Moya

public struct DiawiFile: MultipartFormDataProvider {
    var fileURL: URL
    var fileName: String
    var token: String
    var emails: String
    
    public init(_ url: URL, fileName: String? = nil, token: String, emails: String) {
        self.fileURL = url
        self.fileName = fileName ?? url.lastPathComponent
        self.token = token
        self.emails = emails
    }
    
    public var formDatas: [MultipartFormData] {
        var datas = [
            MultipartFormData(provider: .file(fileURL), name: "file", fileName: fileName, mimeType: nil)
        ]
        if let data = token.data(using: .utf8) {
            datas.append(MultipartFormData(provider: .data(data), name: "token", fileName: nil, mimeType: "plain/txt"))
        }
        if let emails = emails.data(using: .utf8) {
            datas.append(MultipartFormData(provider: .data(emails), name: "callback_emails", fileName: nil, mimeType: "plain/txt"))
        }
        return datas
    }
}
