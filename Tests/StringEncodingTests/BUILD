load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "StringEncodingLib",
    srcs = [
        "GTMStringEncodingTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/StringEncoding:StringEncoding",
        "//UnitTesting:SenTestCase",
        "//:Defines",
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
