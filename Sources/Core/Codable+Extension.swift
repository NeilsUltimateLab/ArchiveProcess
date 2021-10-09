//
//  File.swift
//  
//
//  Created by Neil Jain on 9/26/21.
//

import Foundation

public enum EncodingError: Error {
    case canNotSeriealize
}

public extension Encodable {
    func json() throws -> [String: Any] {
        let jsonData = try JSONEncoder().encode(self)
        let encoded = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        guard let dictionary = encoded as? [String: Any] else {
            throw EncodingError.canNotSeriealize
        }
        return dictionary
    }
    
    func write(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if #available(macOS 10.13, *) {
            encoder.outputFormatting.insert(.sortedKeys)
        }
        let data = try encoder.encode(self)
        try data.write(to: url)
    }
    
    func write(toPath path: String) throws {
        try write(to: URL(fileURLWithPath: path))
    }
}

public extension Decodable {
    static func stored(at url: URL) throws -> Self {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    static func stored(atPath path: String) throws -> Self {
        try stored(at: URL(fileURLWithPath: path))
    }
}
