load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSString_XMLLib",
    testonly = 1,
    non_arc_srcs = [
        "GTMNSString+XMLTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/NSString_XML",
        "//UnitTesting:SenTestCase",
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
