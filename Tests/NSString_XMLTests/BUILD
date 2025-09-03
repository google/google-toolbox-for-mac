load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSString_XMLLib",
    non_arc_srcs = [
        "GTMNSString+XMLTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/NSString_XML:NSString_XML",
        "//UnitTesting:SenTestCase",
        "//:Defines",
    ],
)

ios_unit_test(
    name = "NSString_XMLUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":NSString_XMLLib",
    ],
)

macos_unit_test(
    name = "NSString_XMLMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":NSString_XMLLib",
    ],
)
