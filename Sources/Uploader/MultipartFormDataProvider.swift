//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation
import Moya

public protocol MultipartFormDataProvider {
    var formDatas: [MultipartFormData] { get }
}
