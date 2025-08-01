load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "KVOLib",
    testonly = 1,
    non_arc_srcs = [
        "GTMNSObject+KeyValueObservingTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/KVO:KVO",
        "//:Defines",
        "//DebugUtils",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "KVOUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":KVOLib",
    ],
)

macos_unit_test(
    name = "KVOMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":KVOLib",
    ],
)
