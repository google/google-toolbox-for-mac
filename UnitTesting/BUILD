load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

objc_library(
    name = "TestTimer",
    testonly = 1,
    hdrs = [
        "GTMTestTimer.h",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "SenTestCase",
    testonly = 1,
    hdrs = [
        "GTMSenTestCase.h",
    ],
    defines = ["GTM_USING_XCTEST=1"],
    non_arc_srcs = [
        "GTMSenTestCase.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "SenTestCase_Legacy",
    testonly = 1,
    hdrs = [
        "GTMSenTestCase.h",
    ],
    non_arc_srcs = [
        "GTMSenTestCase.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "FoundationUnitTestingUtilities",
    testonly = 1,
    hdrs = [
        "GTMFoundationUnitTestingUtilities.h",
    ],
    non_arc_srcs = [
        "GTMFoundationUnitTestingUtilities.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

objc_library(
    name = "UnitTestingAppLib",
    testonly = 1,
    hdrs = [
        "GTMCodeCoverageApp.h",
        "GTMIPhoneUnitTestDelegate.h",
    ],
    non_arc_srcs = [
        "GTMIPhoneUnitTestDelegate.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":FoundationUnitTestingUtilities",
        ":SenTestCase_Legacy",
        ":TestTimer",
        "//:Defines",
    ],
)

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":TestTimer",
        ":SenTestCase",
        ":FoundationUnitTestingUtilities",
        ":UnitTestingAppLib",
    ],
)

macos_build_test(
    name = "macOSBuildTest",
    minimum_os_version = "10.10",
    targets = [
        ":TestTimer",
        ":SenTestCase",
        ":FoundationUnitTestingUtilities",
    ],
)
