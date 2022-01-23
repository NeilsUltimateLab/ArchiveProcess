//
//  File.swift
//  
//
//  Created by Neil Jain on 10/9/21.
//

import Foundation

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
            print("Uploaded: \(Int(progress.progress * 100))%")
        } completion: { result in
            switch result {
            case .success(let response):
                if let string = try? response.mapString() {
                    print(string)
                    print(">> Uploaded successfully. Please check your emails! 🎁")
                } else {
                    print("Something went wrong the the upload")
                }
            case .failure(let error):
                print(error)
            }
            onCompletion?()
            Foundation.exit(EXIT_SUCCESS)
        }
        RunLoop.main.run()
    }
}
