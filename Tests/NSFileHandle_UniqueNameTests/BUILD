load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "NSFileHandle_UniqueNameLib",
    testonly = 1,
    non_arc_srcs = [
        "GTMNSFileHandle+UniqueNameTest.m",
    ],
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//:Defines",
        "//Sources/NSFileHandle_UniqueName",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "NSFileHandle_UniqueNameUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":NSFileHandle_UniqueNameLib",
    ],
)

macos_unit_test(
    name = "NSFileHandle_UniqueNameMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":NSFileHandle_UniqueNameLib",
    ],
)
