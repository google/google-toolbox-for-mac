load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSThread_BlocksLib",
    testonly = 1,
    non_arc_srcs = [
        "GTMNSThread+BlocksTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/NSThread_Blocks",
        "//UnitTesting:SenTestCase",
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
