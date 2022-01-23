//
//  File.swift
//  
//
//  Created by Neil Jain on 1/23/22.
//

import Foundation

public protocol Identifiable {
    static var identifier: String { get }
}

public extension Identifiable {
    static var identifier: String {
        String(describing: self)
    }
}
