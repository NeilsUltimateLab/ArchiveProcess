//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation

public extension FileManager {
    func remove(at path: String) {
        guard self.fileExists(atPath: path) else { return }
        try? self.removeItem(atPath: path)
    }
    
    func createDirectory(named directory: String) throws -> String {
        let newDirectoryPath = self.currentDirectoryPath.appending("/\(directory)")
        try self.createDirectory(at: URL(fileURLWithPath: newDirectoryPath), withIntermediateDirectories: true, attributes: nil)
        return newDirectoryPath
    }
}
