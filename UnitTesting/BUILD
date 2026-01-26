load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")
load("@rules_cc//cc:objc_library.bzl", "objc_library")

objc_library(
    name = "SenTestCase",
    testonly = 1,
    hdrs = [
        "SenTestCase/include/GTMSenTestCase.h",
    ],
    includes = ["SenTestCase/include"],
    non_arc_srcs = [
        "SenTestCase/GTMSenTestCase.m",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//:Defines",
    ],
)

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":SenTestCase",
    ],
)

macos_build_test(
    name = "macOSBuildTest",
    minimum_os_version = "10.10",
    targets = [
        ":SenTestCase",
    ],
)
