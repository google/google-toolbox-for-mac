load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "StringEncodingLib",
    testonly = 1,
    srcs = [
        "GTMStringEncodingTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/StringEncoding",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "StringEncodingUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":StringEncodingLib",
    ],
)

macos_unit_test(
    name = "StringEncodingMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":StringEncodingLib",
    ],
)
