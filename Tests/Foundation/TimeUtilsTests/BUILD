load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "TimeUtilsLib",
    srcs = [
        "GTMTimeUtilsTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/TimeUtils:TimeUtils",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

ios_unit_test(
    name = "TimeUtilsUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":TimeUtilsLib",
    ],
)

macos_unit_test(
    name = "TimeUtilsMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":TimeUtilsLib",
    ],
)
