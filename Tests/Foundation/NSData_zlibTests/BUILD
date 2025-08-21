load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSData_zlibLib",
    srcs = [
        "GTMNSData+zlibTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    sdk_dylibs = ["libz"],
    deps = [
        "//Sources/Foundation/NSData_zlib:NSData_zlib",
        "//:Defines",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "NSData_zlibUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":NSData_zlibLib",
    ],
)

macos_unit_test(
    name = "NSData_zlibMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":NSData_zlibLib",
    ],
)
