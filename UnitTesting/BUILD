load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":TestTimer",
        ":SenTestCase",
        ":FoundationUnitTestingUtilities",
        ":UnitTestingAppLib"
    ],
)

objc_library(
    name = "TestTimer",
    hdrs = [
        "GTMTestTimer.h",
    ],
    deps = [
        "//:Defines",
    ]
)

objc_library(
    name = "SenTestCase",
    hdrs = [
        "GTMSenTestCase.h",
    ],
    non_arc_srcs = [
        "GTMSenTestCase.m",
    ],
    deps = [
        "//:Defines",
    ]
)

objc_library(
    name = "FoundationUnitTestingUtilities",
    hdrs = [
        "GTMFoundationUnitTestingUtilities.h",
    ],
    non_arc_srcs = [
        "GTMFoundationUnitTestingUtilities.m",
    ],
    deps = [
        "//:Defines",
    ]
)

objc_library(
    name = "UnitTestingAppLib",
    hdrs = [
        "GTMCodeCoverageApp.h",
        "GTMIPhoneUnitTestDelegate.h"
    ],
    non_arc_srcs = [
        "GTMIPhoneUnitTestDelegate.m"
    ],
    deps = [
        "//:Defines",
        ":TestTimer",
        ":SenTestCase",
        ":FoundationUnitTestingUtilities"
    ]
)
