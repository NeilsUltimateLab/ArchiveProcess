//
//  File.swift
//  
//
//  Created by Neil Jain on 1/23/22.
//

import Foundation

public func log(_ argument: String, with color: String.ConsoleColor = .default) {
    print(argument.colorised(to: color))
}

extension String {
    public enum ConsoleColor: String {
        case black = "30"
        case red = "31"
        case green = "32"
        case yellow = "33"
        case blue = "34"
        case pink = "35"
        case cyan = "36"
        case gray = "37"
        case white = "38"
        case backgroundBlack = "40"
        case backgroundBed = "41"
        case backgroundBreen = "42"
        case backgroundBellow = "43"
        case backgroundBlue = "44"
        case backgroundBink = "45"
        case backgroundByan = "46"
        case backgroundBray = "47"
        case `default` = "0"
    }
    public func colorised(to color: ConsoleColor = .black) -> String {
        "\u{001B}[0;\(color.rawValue)m\(self)\u{001B}[0;0m"
    }
}

extension String.StringInterpolation {
    public mutating func appendInterpolation<T>(_ value: T, color: String.ConsoleColor) {
        appendLiteral("\(value)".colorised(to: color))
    }
}
