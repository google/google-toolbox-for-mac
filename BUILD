load("@build_bazel_rules_apple//apple:ios.bzl", "ios_build_test")
load("@build_bazel_rules_apple//apple:macos.bzl", "macos_build_test")

objc_library(
    name = "Defines",
    hdrs = ["Sources/Defines/Public/GTMDefines.h"],
    includes = ["Sources/Defines/Public"],
    visibility = ["//visibility:public"],
)

ios_build_test(
    name = "iOSBuildTest",
    minimum_os_version = "12.0",
    targets = [
        ":Defines",
    ],
)

macos_build_test(
    name = "macOSBuildTest",
    minimum_os_version = "10.10",
    targets = [
        ":Defines",
    ],
)
