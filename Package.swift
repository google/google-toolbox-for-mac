// swift-tools-version:6.0
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
            path: "spm/GTMDefines"
        ),
        .target(
            name: "GTMLogger",
            dependencies: [
                "GTMDefines"
            ],
            path: "spm/GTMLogger"

        ),
        .target(
            name: "GTMNSData_zlib",
            dependencies: [
                "GTMDefines"
            ],
            path: "spm/GTMNSData_zlib",
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "GTMStringEncoding",
            dependencies: [
                "GTMDefines"
            ],
            path: "spm/GTMStringEncoding"
        ),
    ]
)
