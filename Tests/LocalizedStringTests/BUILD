load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "LocalizedStringLib",
    testonly = 1,
    srcs = [
        "GTMLocalizedStringTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/LocalizedString",
        "//UnitTesting:SenTestCase",
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
