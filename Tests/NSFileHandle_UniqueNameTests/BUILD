load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "NSFileHandle_UniqueNameLib",
    non_arc_srcs = [
        "GTMNSFileHandle+UniqueNameTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/NSFileHandle_UniqueName:NSFileHandle_UniqueName",
        "//UnitTesting:SenTestCase",
        "//:Defines",
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
