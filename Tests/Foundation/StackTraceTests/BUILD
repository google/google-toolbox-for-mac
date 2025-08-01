load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "StackTraceLib",
    non_arc_srcs = [
        "GTMStackTraceTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/StackTrace:StackTrace",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

ios_unit_test(
    name = "StackTraceUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":StackTraceLib",
    ],
)

macos_unit_test(
    name = "StackTraceMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":StackTraceLib",
    ],
)
