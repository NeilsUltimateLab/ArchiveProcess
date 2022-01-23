//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation
import Utilities

public struct Uploader {
    public var file: DiawiFile
    public var onCompletion: (()->Void)?
    var uploader = DiawiUploader()
    
    public init(file: DiawiFile, onCompletion: (()->Void)? = nil) {
        self.file = file
        self.onCompletion = onCompletion
    }
    
    public func run() {
        uploader.upload(file) { progress in
            log("Uploaded: \(Int(progress.progress * 100))%", with: .green)
        } completion: { result in
            switch result {
            case .success(let response):
                if let string = try? response.mapString() {
                    print(string)
                    log(">> Uploaded successfully. Please check your emails! 🎁", with: .green)
                } else {
                    log("Something went wrong the the upload", with: .red)
                }
            case .failure(let error):
                print(error)
            }
            onCompletion?()
        }
        RunLoop.main.run()
    }
}
