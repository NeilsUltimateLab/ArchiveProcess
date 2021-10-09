//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation
import Moya

enum DiawiTarget {
    case upload(MultipartFormDataProvider)
}

extension DiawiTarget: TargetType {
    var baseURL: URL {
        URL(string: "https://upload.diawi.com")!
    }
    
    var path: String {
        switch self {
        case .upload:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .upload:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .upload(let provider):
            return .uploadMultipart(provider.formDatas)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
}
