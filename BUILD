load("@rules_cc//cc:defs.bzl", "objc_library")
load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":Defines",
    ],
)

objc_library(
    name = "Defines",
    hdrs = ["GTMDefines.h"],
    includes = ["."],
    visibility = ["//visibility:public"],
)
