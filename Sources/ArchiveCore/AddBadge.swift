//
//  File.swift
//  
//
//  Created by Neil Jain on 2/5/22.
//

import Foundation
import ArgumentParser
import Utilities
import CoreImage

public enum AddBadgeError: Error {
    case canNotFindBadgeFilePath
    case canNotFindProjectPath
    case canNotFindAssetsDirectory
    case canNotFindAssets
    case canNotDecodeImage
    case couldNotResetBadge
}


public struct AddBadge: ParsableCommand, MeasuredCommand {
    @Argument
    public var badgeImagePath: String?
    
    @Argument
    public var projectPath: String?
    
    @Flag
    public var reset: Bool = false
    
    public init() {}
    
    public func run() throws {
        try self.measure {
            guard let projectPath = projectPath else {
                throw AddBadgeError.canNotFindProjectPath
            }
            let projectURL = URL(fileURLWithPath: projectPath)
            guard let assetsURL = assetPath(for: projectURL) else {
                throw AddBadgeError.canNotFindAssetsDirectory
            }
            
            if reset == true {
                try resetBadge(for: assetsURL)
                return
            }
            
            guard let path = self.badgeImagePath else {
                throw AddBadgeError.canNotFindBadgeFilePath
            }
            
            let url = URL(fileURLWithPath: path)
            
            guard let appIconPath = appIconPath(for: assetsURL) else {
                throw AddBadgeError.canNotFindAssets
            }
            guard let images = icons(for: appIconPath) else {
                throw AddBadgeError.canNotFindAssets
            }
            for image in images {
                let composedImages = compose(iconURL: image, badgeURL: url)
                try composedImages?.export(to: image)
            }
        }
    }
    
    private func appIconPath(for assetsPath: URL) -> URL? {
        guard let enumarator = FileManager.default.enumerator(atPath: assetsPath.path) else {
            return nil
        }
        for case let path as String in enumarator {
            if path == "AppIcon.appiconset" {
                let url = URL(fileURLWithPath: path, relativeTo: assetsPath)
                return url
            }
        }
        return nil
    }
    
    private func icons(for path: URL) -> [URL]? {
        guard let enumarator = FileManager.default.enumerator(atPath: path.path) else { return nil }
        var images = [URL]()
        for case let imagePath as String in enumarator {
            let url = URL(fileURLWithPath: imagePath, relativeTo: path)
            images.append(url)
        }
        return images
    }
    
    private func assetPath(for projectPath: URL) -> URL? {
        log("Finding assets library for project path: \(projectPath.path)", with: .yellow)
        guard let enumarator = FileManager.default.enumerator(atPath: projectPath.path) else { return nil }
        for case let path as String in enumarator {
            if path.hasSuffix("Assets.xcassets") {
                return URL(fileURLWithPath: path, relativeTo: projectPath)
            }
        }
        return nil
    }
    
    private func compose(iconURL: URL, badgeURL: URL) -> CIImage? {
        guard let iconImage = CIImage(contentsOf: iconURL),
                let badgeImage = CIImage(contentsOf: badgeURL)
        else { return nil }
        guard let resizedBadge = resize(image: badgeImage, to: iconImage.extent.size) else {
            log("Can not resize badge image at \(badgeURL)", with: .red)
            return nil
        }
        return compose(iconImage: iconImage, badgeImage: resizedBadge)
    }
    
    private func resize(image: CIImage, to size: CGSize) -> CIImage? {
        guard let scaleFilter = CIFilter(name: "CILanczosScaleTransform") else { fatalError() }
        let scale = size.height / image.extent.height
        let aspectRatio = size.width / (image.extent.width * scale)
        
        scaleFilter.setValue(image, forKey: kCIInputImageKey)
        scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
        scaleFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return scaleFilter.outputImage
    }
    
    private func compose(iconImage: CIImage, badgeImage: CIImage) -> CIImage {
        badgeImage.composited(over: iconImage)
    }
    
    private func resetBadge(for assetsPath: URL) throws {
        let command = "git restore \(assetsPath.path)"
        try Process.runAndThrow(command, error: AddBadgeError.couldNotResetBadge)
    }
    
}

extension CIImage {
    func export(to destination: URL) throws {
        let context = CIContext()
        try context.writePNGRepresentation(of: self, to: destination, format: .RGBA16, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, options: [:])
        log("Added badge at: \(destination.path)", with: .green)
    }
}
