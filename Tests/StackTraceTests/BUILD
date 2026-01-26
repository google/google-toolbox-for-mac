load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "StackTraceLib",
    testonly = 1,
    non_arc_srcs = [
        "GTMStackTraceTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/StackTrace",
        "//UnitTesting:SenTestCase",
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
