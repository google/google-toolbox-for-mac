// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GoogleToolboxForMac",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "GTMLogger",
            targets: ["GTMLogger"]
        ),
        .library(
            name: "GTMNSData_zlib",
            targets: ["GTMNSData_zlib"]
        ),
        .library(
            name: "GTMStringEncoding",
            targets: ["GTMStringEncoding"]
        ),
    ],
    targets: [
        .target(
            name: "GTMDefines",
            path: "Sources/Foundation/Defines"
        ),
        .target(
            name: "GTMLogger",
            dependencies: [
                "GTMDefines"
            ],
            path: "Sources/Foundation/Logger",
            exclude: [
                "GTMLogger+ASL.m",
                "GTMLoggerRingBufferWriter.m"
            ],
            publicHeadersPath: "Public"
        ),
        .target(
            name: "GTMNSData_zlib",
            dependencies: [
                "GTMDefines"
            ],
            path: "Sources/Foundation/NSData_zlib",
            publicHeadersPath: "Public",
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "GTMStringEncoding",
            dependencies: [
                "GTMDefines"
            ],
            path: "Sources/Foundation/StringEncoding",
            publicHeadersPath: "Public"
        ),
    ]
)
