load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSString_HTMLLib",
    testonly = 1,
    srcs = [
        "GTMNSString+HTMLTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/NSString_HTML",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "NSString_HTMLUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":NSString_HTMLLib",
    ],
)

macos_unit_test(
    name = "NSString_HTMLMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":NSString_HTMLLib",
    ],
)
