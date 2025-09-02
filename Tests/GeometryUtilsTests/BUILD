load("@build_bazel_rules_apple//apple:ios.bzl", "ios_unit_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_unit_test")

objc_library(
    name = "GeometryUtilsLib",
    srcs = [
        "GTMGeometryUtilsTest.m",
    ],
    testonly = 1,
    sdk_frameworks = [
        "XCTest",
    ],
    deps = [
        "//Sources/GeometryUtils:GeometryUtils",
        "//UnitTesting:SenTestCase",
    ],
)

ios_unit_test(
    name = "GeometryUtilsUnitTest",
    minimum_os_version = "12.0",
    deps = [
        ":GeometryUtilsLib",
    ],
)

macos_unit_test(
    name = "GeometryUtilsMacOSUnitTest",
    minimum_os_version = "10.10",
    deps = [
        ":GeometryUtilsLib",
    ],
)
