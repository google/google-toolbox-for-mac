load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "LocalizedStringLib",
    srcs = [
        "GTMLocalizedStringTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/Foundation/LocalizedString:LocalizedString",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

ios_unit_test(
    name = "LocalizedStringUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":LocalizedStringLib",
    ],
)

macos_unit_test(
    name = "LocalizedStringMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":LocalizedStringLib",
    ],
)
