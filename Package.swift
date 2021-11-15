// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArchiveProcess",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "ArchiveProcess",
            targets: ["ArchiveProcess"]
        ),
        .executable(
            name: "PrePush",
            targets: ["PrePush"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "Gzip", url: "https://github.com/1024jp/GzipSwift", from: "5.1.1"),
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0")),
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", from: "1.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "ArchiveProcess",
            dependencies: [
                "Core",
                "Gzip",
                "Uploader",
                "ArchiveCore",
                "Moya",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "PrePush",
            dependencies: [
                "ArchiveCore",
                "Uploader",
                "Core"
            ]
        ),
        .target(name: "ArchiveCore", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "Uploader",
            "Core"
        ]),
        .target(name: "Core"),
        .target(name: "Uploader", dependencies: [
            "Moya"
        ]),
        .testTarget(
            name: "ArchiveProcessTests",
            dependencies: [
                "ArchiveProcess",
                "Moya",
                "Gzip",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
    ]
)
