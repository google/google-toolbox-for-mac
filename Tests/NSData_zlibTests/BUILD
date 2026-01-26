load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSData_zlibLib",
    testonly = 1,
    srcs = [
        "GTMNSData+zlibTest.m",
    ],
    sdk_dylibs = ["libz"],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/NSData_zlib",
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
