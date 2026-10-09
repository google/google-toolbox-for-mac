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
    )
  ],
  targets: [
    .target(
      name: "GTMDefines",
      path: "Sources/Defines",
      publicHeadersPath: "Public"
    ),
    .target(
      name: "GTMLogger",
      dependencies: [
        "GTMDefines"
      ],
      path: "Sources/Logger",
      exclude: [
        "BUILD",
        "GTMLogger+ASL.m",
        "GTMLoggerRingBufferWriter.m",
      ],
      publicHeadersPath: "Public/Foundation"
    ),
    .target(
      name: "GTMNSData_zlib",
      dependencies: [
        "GTMDefines"
      ],
      path: "Sources/NSData_zlib",
      exclude: [
        "BUILD"
      ],
      publicHeadersPath: "Public/Foundation",
      linkerSettings: [
        .linkedLibrary("z")
      ]
    ),
    .target(
      name: "GTMStringEncoding",
      dependencies: [
        "GTMDefines"
      ],
      path: "Sources/StringEncoding",
      exclude: [
        "BUILD"
      ],
      publicHeadersPath: "Public/Foundation"
    ),
    .target(
      name: "SenTestCase",
      dependencies: [
        "GTMDefines"
      ],
      path: "UnitTesting/SenTestCase",
      exclude: [
        "GTMSenTestCaseTest.m"
      ]
    ),
    .testTarget(
      name: "GTMLoggerTests",
      dependencies: ["GTMLogger", "SenTestCase"],
      path: "Tests/LoggerTests",
      exclude: [
        "BUILD",
        "GTMLogger+ASLTest.m",
        "GTMLoggerRingBufferWriterTest.m",
      ]
    ),
    .testTarget(
      name: "NSData_zlibTests",
      dependencies: ["GTMNSData_zlib", "SenTestCase"],
      path: "Tests/NSData_zlibTests",
      exclude: [
        "BUILD"
      ]
    ),
    .testTarget(
      name: "StringEncodingTests",
      dependencies: ["GTMStringEncoding", "SenTestCase"],
      path: "Tests/StringEncodingTests",
      exclude: [
        "BUILD"
      ]
    )
  ]
)
