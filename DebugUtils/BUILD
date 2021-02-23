load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

objc_library(
    name = "TypeCasting",
    hdrs = [
        "GTMTypeCasting.h",
    ],
    visibility = ["//visibility:public"],
)

objc_library(
    name = "DebugUtils",
    hdrs = [
        "GTMDebugSelectorValidation.h",
        "GTMDebugThreadValidation.h",
        "GTMMethodCheck.h",
    ],
    copts = [
        "-IDebugUtils",
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
        ":TypeCasting",
        ":DebugUtils",
    ],
)

macos_build_test(
    name = "macOSBuildTest",
    minimum_os_version = "10.10",
    targets = [
        ":TypeCasting",
        ":DebugUtils",
    ],
)
