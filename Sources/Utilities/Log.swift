//
//  File.swift
//  
//
//  Created by Neil Jain on 1/23/22.
//

import Foundation

public func log(_ argument: String, with color: ConsoleColor = .default) {
    print(argument.colorised(to: color))
}

extension String {
    public func colorised(to color: ConsoleColor = .black) -> String {
        "\u{001B}[0;\(color.rawValue)m\(self)\u{001B}[0;0m"
    }
}

extension String.StringInterpolation {
    public mutating func appendInterpolation<T>(_ value: T, color: ConsoleColor) {
        appendLiteral("\(value)".colorised(to: color))
    }
}

extension String {
    public init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer({ pointer in
            String(decoding: pointer, as: UTF8.self)
        })
    }
}

