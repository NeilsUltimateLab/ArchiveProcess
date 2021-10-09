//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation
import Moya

public class DiawiUploader {
    
    public init() {}
    
    private var provider: MoyaProvider<DiawiTarget> = {
        let logger = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let provider = MoyaProvider<DiawiTarget>(plugins: [logger])
        return provider
    }()
    
    public func upload(_ dataProvider: MultipartFormDataProvider, progress: ProgressBlock?, completion: @escaping Completion) {
        provider.request(.upload(dataProvider), progress: progress, completion: completion)
    }
    
    public func upload(file: DiawiFile, progress: ProgressBlock?, completion: @escaping Completion) {
        upload(file, progress: progress, completion: completion)
    }
    
}
