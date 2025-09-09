load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSString_HTMLLib",
    srcs = [
        "GTMNSString+HTMLTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/NSString_HTML:NSString_HTML",
        "//UnitTesting:SenTestCase",
        "//:Defines",
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
