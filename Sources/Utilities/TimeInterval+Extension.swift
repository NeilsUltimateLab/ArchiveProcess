//
//  File.swift
//  
//
//  Created by Neil Jain on 1/23/22.
//

import Foundation

public extension TimeInterval {
    static var dateComponentFormatter: DateComponentsFormatter = {
        DateComponentsFormatter()
    }()
    
    var durationString: String? {
        let ms = Int(self.truncatingRemainder(dividingBy: 1) * 1000)
        let formatter = Self.dateComponentFormatter
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        let string = formatter.string(from: self)?.appending(".\(ms)ms")
        return string
    }
}
