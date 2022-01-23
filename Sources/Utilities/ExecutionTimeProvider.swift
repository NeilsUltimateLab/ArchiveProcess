//
//  File.swift
//  
//
//  Created by Neil Jain on 1/23/22.
//

import Foundation
import SwiftyTextTable

public protocol ExecutionTimeProvider: Identifiable {
    func measure(_ task: () throws -> Void) throws
}

public extension ExecutionTimeProvider {
    func measure(_ task: () throws -> Void) throws {
        let startDate = Date()
        try task()
        Self.store(duration: Date().timeIntervalSince(startDate))
    }
}

public extension ExecutionTimeProvider {
    static func store(duration: TimeInterval) {
        let profile = ExecutionProfile.Profile(name: Self.identifier, duration: duration)
        ExecutionProfile.profiles.append(profile)
        log([profile].renderTextTable(), with: .green)
    }
}

public enum ExecutionProfile {
    struct Profile {
        var name: String
        var duration: TimeInterval
    }
    
    static var profiles: [Profile] = []
    
    static func total() -> Profile {
        Profile(name: "Total", duration: self.profiles.map({$0.duration}).reduce(0, +))
    }
    
    public static func renderProfile() {
        var profiles = profiles
        profiles.append(total())
        log(profiles.renderTextTable(), with: .green)
    }
}

extension ExecutionProfile.Profile: TextTableRepresentable {
    static var columnHeaders: [String] {
        ["Process Name", "Duration"]
    }
    
    var tableValues: [CustomStringConvertible] {
        [self.name, self.duration.durationString ?? "Os"]
    }
    
    static var tableHeader: String? {
        "Archive Process Execution Profile"
    }
}
