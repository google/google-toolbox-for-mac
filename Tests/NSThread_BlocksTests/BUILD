load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSThread_BlocksLib",
    non_arc_srcs = [
        "GTMNSThread+BlocksTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/NSThread_Blocks:NSThread_Blocks",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

ios_unit_test(
    name = "NSThread_BlocksUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":NSThread_BlocksLib",
    ],
)

macos_unit_test(
    name = "NSThread_BlocksMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":NSThread_BlocksLib",
    ],
)
