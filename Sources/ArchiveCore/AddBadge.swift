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
    @Argument(help: "Path of the image that will be overlaped to the projects AppIcon images.")
    public var badgeImagePath: String?
    
    @Argument(help: "Path of the project in which Assets.xcassets resides")
    public var projectPath: String?
    
    @Flag(help: "Reset the overlaped images using `git restore` command")
    public var reset: Bool = false
    
    public init() {}
    
    /// Runs several commands sequence with time measurement.
    public func run() throws {
        try self.measure {
            // Gets the project path and generate URL
            guard let projectPath = projectPath else {
                throw AddBadgeError.canNotFindProjectPath
            }
            let projectURL = URL(fileURLWithPath: projectPath)
            
            // Gets the assets library path and get URL
            guard let assetsURL = assetPath(for: projectURL) else {
                throw AddBadgeError.canNotFindAssetsDirectory
            }
            
            // If reset flag passed then reset the AppIcon images and return.
            if reset == true {
                try resetBadge(for: assetsURL)
                return
            }
            
            // Gets the badge Image Path and generate URL
            guard let path = self.badgeImagePath else {
                throw AddBadgeError.canNotFindBadgeFilePath
            }
            let url = URL(fileURLWithPath: path)
            
            // Gets the AppIcon images path
            guard let appIconPath = appIconPath(for: assetsURL) else {
                throw AddBadgeError.canNotFindAssets
            }
            
            // Gets all images inside AppIcon image asset.
            guard let images = icons(for: appIconPath) else {
                throw AddBadgeError.canNotFindAssets
            }
            
            // Composite badge image over every app icon image.
            for image in images {
                let composedImages = compose(iconURL: image, badgeURL: url)
                try composedImages?.export(to: image)
            }
        }
    }
    
    /// Returns the Path URL for `AppIcon.appiconset` using FileManager's enumarator.
    /// - Parameter assetsPath: Path for the assets library `Assets.xcassets`
    /// - Returns: URL for the `AppIcon.appiconset`
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
    
    /// Returns the all the image paths inside given path
    /// - Parameter path: Path of the `AppIcon.appiconset`
    /// - Returns: All Content's path url
    private func icons(for path: URL) -> [URL]? {
        guard let enumarator = FileManager.default.enumerator(atPath: path.path) else { return nil }
        var images = [URL]()
        for case let imagePath as String in enumarator {
            let url = URL(fileURLWithPath: imagePath, relativeTo: path)
            images.append(url)
        }
        return images
    }
    
    /// Returns the Path for the `Assets.xcassets` directory.
    /// - Parameter projectPath: Path of the project.
    /// - Returns: Path url for the `Assets.xcassets`.
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
    
    /// Creates the CIImages from badge and app icon and return the composite image.
    /// - Parameters:
    ///   - iconURL: App Icon path
    ///   - badgeURL: Badge Image Path
    /// - Returns: Composite image overlaping Badge Image to App Icon.
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
    
    /// Resize the CIImage using `CILanczosScaleTransform` filter.
    /// - Parameters:
    ///   - image: image to resize
    ///   - size: Resize dimension
    /// - Returns: Resized image.
    private func resize(image: CIImage, to size: CGSize) -> CIImage? {
        guard let scaleFilter = CIFilter(name: "CILanczosScaleTransform") else { fatalError() }
        let scale = size.height / image.extent.height
        let aspectRatio = size.width / (image.extent.width * scale)
        
        scaleFilter.setValue(image, forKey: kCIInputImageKey)
        scaleFilter.setValue(scale, forKey: kCIInputScaleKey)
        scaleFilter.setValue(aspectRatio, forKey: kCIInputAspectRatioKey)
        return scaleFilter.outputImage
    }
    
    /// Composite/Overlap the badgeImage on App Icon image.
    /// - Parameters:
    ///   - iconImage: base image
    ///   - badgeImage: overlap image
    /// - Returns: Composite output image
    private func compose(iconImage: CIImage, badgeImage: CIImage) -> CIImage {
        badgeImage.composited(over: iconImage)
    }
    
    /// Resets the `Assets.xcassets` using `git restore` command.
    /// - Parameter assetsPath: path for the `Assets.xcassets`.
    private func resetBadge(for assetsPath: URL) throws {
        let command = "git restore \(assetsPath.path)"
        try Process.runAndThrow(command, error: AddBadgeError.couldNotResetBadge)
    }
    
}

extension CIImage {
    
    /// Writes the PNG representation to the destination URL using `.RGBA16` format in `.sRGB` colorSpace.
    /// - Parameter destination: Path to save image.
    func export(to destination: URL) throws {
        let context = CIContext()
        try context.writePNGRepresentation(of: self, to: destination, format: .RGBA16, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, options: [:])
        log("Added badge at: \(destination.path)", with: .green)
    }
}
