load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "TimeUtilsLib",
    testonly = 1,
    srcs = [
        "GTMTimeUtilsTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/TimeUtils",
        "//UnitTesting:SenTestCase",
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
